// spawn resources

#include "RulesCore.as";
#include "CTF_Structs.as";
#include "CrouchCommon.as";

const u32 materials_wait = 20; //seconds between free mats
const u32 materials_wait_warmup = 40; //seconds between free mats

//property
const string SPAWN_ITEMS_TIMER_BUILDER = "CTF SpawnItems Builder:";
const string SPAWN_ITEMS_TIMER_ARCHER  = "CTF SpawnItems Archer:";

string base_name() { return "tent"; }

bool SetMaterials(CBlob@ blob,  const string &in name, const int quantity, bool drop = false)
{
	CInventory@ inv = blob.getInventory();
	
	//avoid over-stacking arrows
	if (name == "mat_arrows")
	{
		inv.server_RemoveItems(name, quantity);
	}
	
	CBlob@ mat = server_CreateBlobNoInit(name);
	
	if (mat !is null)
	{
		mat.Tag('custom quantity');
		mat.Init();
		
		mat.server_SetQuantity(quantity);
		
		if (drop || not blob.server_PutInInventory(mat))
		{
			mat.setPosition(blob.getPosition());
		}
	}
	
	return true;
}

//when the player is set, give materials if possible
void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
	if (!getNet().isServer()) return;
	
	if (blob is null) return;
	if (player is null) return;
	
	doGiveSpawnMats(this, player, blob);
}

//when player dies, unset archer flag so he can get arrows if he really sucks :)
//give a guy a break :)
void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	if (victim !is null)
	{
		SetCTFTimerArcher(this, victim, 0);
	}
}

string getCTFTimerPropertyNameBuilder(CPlayer@ p)
{
	return SPAWN_ITEMS_TIMER_BUILDER + p.getUsername();
}

s32 getCTFTimerBuilder(CRules@ this, CPlayer@ p)
{
	string property = getCTFTimerPropertyNameBuilder(p);
	if (this.exists(property))
		return this.get_s32(property);
	else
		return 0;
}

void SetCTFTimerBuilder(CRules@ this, CPlayer@ p, s32 time)
{
	string property = getCTFTimerPropertyNameBuilder(p);
	this.set_s32(property, time);
	this.SyncToPlayer(property, p);
}

string getCTFTimerPropertyNameArcher(CPlayer@ p)
{
	return SPAWN_ITEMS_TIMER_ARCHER + p.getUsername();
}

s32 getCTFTimerArcher(CRules@ this, CPlayer@ p)
{
	string property = getCTFTimerPropertyNameArcher(p);
	if (this.exists(property))
		return this.get_s32(property);
	else
		return 0;
}

void SetCTFTimerArcher(CRules@ this, CPlayer@ p, s32 time)
{
	string property = getCTFTimerPropertyNameArcher(p);
	this.set_s32(property, time);
	this.SyncToPlayer(property, p);
}

void GetMatsToReceive(CRules@ this, CPlayer@ p, int &out wood_amount, int &out stone_amount, string modifier="none")
{
	f32 playerCount = CountPlayersInTeam(p.getTeamNum());
	wood_amount = 100;
	stone_amount = 30;
	
	if (modifier=="controlpoint")
	{
			wood_amount = 500;
			stone_amount = 150;

			wood_amount /= (1.05 * playerCount);
			wood_amount *= 0.75f;
			stone_amount /= (1.05 * playerCount);
			stone_amount *= 0.75f;
	}
	else
	{
		if (this.isWarmup()) 
		{
			wood_amount = 1200;
			stone_amount = 500;

			wood_amount /= playerCount;
			stone_amount /= playerCount;
		}
		else
		{
			wood_amount = 500;
			stone_amount = 150;

			wood_amount /= (1.05 * playerCount);
			stone_amount /= (1.05 * playerCount);
		}
	}
}

//takes into account and sets the limiting timer
//prevents dying over and over, and allows getting more mats throughout the game
void doGiveSpawnMats(CRules@ this, CPlayer@ p, CBlob@ b, string modifier="none")
{
	s32 gametime = getGameTime();
	string name = b.getName();
	if (name == "archer") 
	{
		if (gametime > getCTFTimerArcher(this, p)) 
		{
			if (SetMaterials(b, "mat_arrows", 30)) 
			{
				SetCTFTimerArcher(this, p, gametime + (this.isWarmup() ? materials_wait_warmup : materials_wait)*getTicksASecond());
			}
		}
	}
}

// normal hooks

void Reset(CRules@ this)
{
	//restart everyone's timers
	for (uint i = 0; i < getPlayersCount(); ++i) {
		SetCTFTimerArcher(this, getPlayer(i), 0);
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	s32 next_add = getGameTime() + (this.isWarmup() ? materials_wait_warmup : materials_wait)*getTicksASecond();

	if (next_add < getCTFTimerArcher(this, player) || next_add < getCTFTimerBuilder(this, player))
	{
		SetCTFTimerArcher(this, player, getGameTime());
	}
}

void onRestart(CRules@ this)
{
	this.Untag("givengold");
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
}

void onStateChange( CRules@ this, const u8 oldState )
{
	if(this.getCurrentState() == GAME)
	{
		this.set_u32("nextresupplytime", getGameTime() + (60 * getTicksASecond()));

		if(!isServer()) return;

		CBlob@[] blist;

		string[] blue_builders;
		string[] red_builders;
		for (int i=0; i<getPlayersCount(); ++i)
		{
			if(getPlayer(i).getBlob() is null) continue;

			if (getPlayer(i).getBlob().getName() == "builder")
			{
				if (getPlayer(i).getTeamNum() == 0) blue_builders.push_back(getPlayer(i).getUsername());
				else if (getPlayer(i).getTeamNum() == 1) red_builders.push_back(getPlayer(i).getUsername());
			}
		}

		if (getBlobsByName("tent", blist))
		{
			for(uint step=0; step<blist.length; ++step)
			{
				if(blist[step].getTeamNum() == 0)
				{
					u16 mat_wood_count = 0;
					u16 mat_stone_count = 0;
					CInventory@ inv = blist[step].getInventory();
					int current = 0;
					for(int k=0; k<inv.getItemsCount(); ++k)
					{
						CBlob@ currentitem = inv.getItem(k);
						if(currentitem.getName() == "mat_wood") mat_wood_count += currentitem.getQuantity();
						if(currentitem.getName() == "mat_stone") mat_stone_count += currentitem.getQuantity();
					}
					if(blue_builders.length > 0)
					{
						for (int p=0; p<blue_builders.length; ++p)
						{
							CPlayer@ current_player = getPlayerByUsername(blue_builders[p]);

							if(current_player !is null)
							{
								if(current_player.getBlob() !is null)
								{
									blist[step].TakeBlob("mat_wood", (mat_wood_count / blue_builders.length));
									blist[step].TakeBlob("mat_stone", (mat_stone_count / blue_builders.length));
									SetMaterials(current_player.getBlob(), "mat_wood", (mat_wood_count / blue_builders.length), true);
									SetMaterials(current_player.getBlob(), "mat_stone", (mat_stone_count / blue_builders.length), true); 
								}
							}
						}
					}
					while (inv !is null && (inv.getItemsCount() > 0))
					{
						blist[step].server_PutOutInventory(inv.getItem(0));
					}
				}
				if(blist[step].getTeamNum() == 1)
				{
					u16 mat_wood_count = 0;
					u16 mat_stone_count = 0;
					CInventory@ inv = blist[step].getInventory();
					int current = 0;
					for(int k=0; k<inv.getItemsCount(); ++k)
					{
						CBlob@ currentitem = inv.getItem(k);
						if(currentitem.getName() == "mat_wood") mat_wood_count += currentitem.getQuantity();
						if(currentitem.getName() == "mat_stone") mat_stone_count += currentitem.getQuantity();
					}
					if(red_builders.length > 0)
					{
						for (int p=0; p<red_builders.length; ++p)
						{
							CPlayer@ current_player = getPlayerByUsername(red_builders[p]);

							if(current_player !is null)
							{
								if(current_player.getBlob() !is null)
								{
									blist[step].TakeBlob("mat_wood", (mat_wood_count / red_builders.length));
									blist[step].TakeBlob("mat_stone", (mat_stone_count / red_builders.length));
									SetMaterials(current_player.getBlob(), "mat_wood", (mat_wood_count / red_builders.length), true);
									SetMaterials(current_player.getBlob(), "mat_stone", (mat_stone_count / red_builders.length), true); 
								}
							}
						}
					}
					while (inv !is null && (inv.getItemsCount() > 0))
					{
						blist[step].server_PutOutInventory(inv.getItem(0));
					}
				}
			}
		}
	}
}

void onTick(CRules@ this)
{
	if (!getNet().isServer())
		return;
	
	s32 gametime = getGameTime();

	//printf("Test. " + getRules().get_u32("match_time") + " , " + );

	if (this.getCurrentState() == WARMUP || this.getCurrentState() == INTERMISSION)
	{
		if (getGameTime() % (40 * getTicksASecond()) == 5)
		{
			CBlob@[] blist;
				
			if (getBlobsByName("tent", blist))
			{
				for(uint step=0; step<blist.length; ++step)
				{
					SetMaterials(blist[step], "mat_wood", 1200, false);
					SetMaterials(blist[step], "mat_stone", 500, false); 
					if(!this.hasTag("givengold"))
					{
						SetMaterials(blist[step], "mat_gold", 200, false); 
					}
				}
				this.Tag("givengold");
				this.Sync("givengold", true);
			}

			this.set_u32("nextresupplytime", getGameTime() + (40 * getTicksASecond()));
			this.Sync("nextresupplytime", true);

		}
	}
	else
	{
		u32 currenttime = getRules().exists("match_time") ? getRules().get_u32("match_time") : getGameTime()/getTicksASecond();

		if(getGameTime() == this.get_u32("nextresupplytime"))
		{
			CBlob@[] blist;
				
			if (getBlobsByName("tent", blist))
			{
				for(uint step=0; step<blist.length; ++step)
				{
					SetMaterials(blist[step], "mat_wood", 400, true);
					SetMaterials(blist[step], "mat_stone", 90, true); 
				}
			}

			this.set_u32("nextresupplytime", getGameTime() + (60 * getTicksASecond()));
			this.Sync("nextresupplytime", true);
		}
	}
	

	if ((gametime % 30) != 5)
		return;


	{
		CBlob@[] spots;
		getBlobsByName(base_name(),   @spots);
		getBlobsByName("ballista",	@spots);
		getBlobsByName("outpost",	@spots);
		getBlobsByName("warboat",	 @spots);
		getBlobsByName("buildershop", @spots);
		getBlobsByName("archershop",  @spots);
		// getBlobsByName("knightshop",  @spots);
		for (uint step = 0; step < spots.length; ++step) 
		{
			CBlob@ spot = spots[step];
			if (spot is null) continue;

			CBlob@[] overlapping;
			if (!spot.getOverlapping(overlapping)) continue;

			string name = spot.getName();
			bool isShop = (name.find("shop") != -1);

			for (uint o_step = 0; o_step < overlapping.length; ++o_step) 
			{
				CBlob@ overlapped = overlapping[o_step];
				if (overlapped is null) continue;
				
				if (!overlapped.hasTag("player")) continue;
				CPlayer@ p = overlapped.getPlayer();
				if (p is null) continue;
				
				if (isShop && name.find(overlapped.getName()) == -1) continue; // NOTE(hobey): builder doesn't get wood+stone at archershop, archer doesn't get arrows at buildershop
					
				doGiveSpawnMats(this, p, overlapped);
			}
		}

	}
}

// render gui for the player
void onRender(CRules@ this)
{
	if (g_videorecording || this.isGameOver())
		return;
	
	CPlayer@ p = getLocalPlayer();
	if (p is null || !p.isMyPlayer()) return;
	
	CBlob@ b = p.getBlob();
	if (b is null) return;
	
	string name = b.getName();
	
	if (name == "builder")
	{
		s32 next_items = this.get_u32("nextresupplytime");
		if (next_items > getGameTime())
		{
			u32 secs = ((next_items - 1 - getGameTime()) / getTicksASecond()) + 1;
			string units = ((secs != 1) ? " seconds" : " second");
			string owomats = "on Tent (400 wood 90 stone)";
			if (this.getCurrentState() == WARMUP || this.getCurrentState() == INTERMISSION) owomats = "(1200 wood 500 stone)";
			GUI::SetFont("menu");
			if (!this.hasTag("ctfgivespawnitems_amogus"))
			{
				GUI::DrawTextCentered(getTranslatedString("Next resupply " + owomats + " in {SEC}{TIMESUFFIX}")
				.replace("{SEC}", "" + secs)
				.replace("{TIMESUFFIX}", getTranslatedString(units)),

			    Vec2f(getScreenWidth() / 2, getScreenHeight() / 3 - 70.0f),
			        SColor(255, 255, 55, 55));
			}
			else if (this.getCurrentState() == GAME)
			{
				GUI::DrawTextCentered(getTranslatedString("Next resupply " + owomats + " in {SEC}{TIMESUFFIX}")
					.replace("{SEC}", "" + secs)
					.replace("{TIMESUFFIX}", getTranslatedString(units)),

			        Vec2f(getScreenWidth() / 2, getScreenHeight() / 3 - 70.0f),
			        SColor(255, 255, 55, 55));
			}
		}
	}
	// TODO(hobey): maybe only draw the cooldown/helptext for archer if low on arrows?
	string propname = getCTFTimerPropertyNameArcher(p);
	if (name == "archer" && this.exists(propname))
	{
		s32 next_items = this.get_s32(propname);
		
		GUI::SetFont("menu");
		
		u32 secs = ((next_items - 1 - getGameTime()) / getTicksASecond()) + 1;
		string units = ((secs != 1) ? " seconds" : " second");
		
		SColor color = SColor(200, 135, 185, 45);
		int wood_amount = 100;
		int stone_amount = 30;
		if (this.isWarmup())
		{
			wood_amount = 300;
			stone_amount = 100;
		}
		string text = getTranslatedString("Go to an archer shop or a respawn point to get a resupply of 30 arrows.");

		Vec2f offset = Vec2f(20, 96);
		float x = getScreenWidth() / 3 + offset.x;
		float y = getScreenHeight() - offset.y;
		
		if (next_items > getGameTime())
		{
			// color = SColor(255, 255, 55, 55);
			color = SColor(255, 255, 55, 55);
			
			text = getTranslatedString("Next resupply of 30 arrows in {SEC}{TIMESUFFIX}.")
				.replace("{SEC}", "" + secs)
				.replace("{TIMESUFFIX}", getTranslatedString(units));

			x = getScreenWidth() / 2;
			y = getScreenHeight() / 3 - 16.0f;
		}
		
		GUI::DrawTextCentered(text, Vec2f(x, y), color);
	}
}

int CountPlayersInTeam(int teamNum) {
    int count = 0;

    for (int i=0; i < getPlayerCount(); i++) {
        CPlayer@ p = getPlayer(i);
        if (p is null) continue;

        if (p.getTeamNum() == teamNum)
            count++;
    }

    return count;
}