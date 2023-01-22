#include "SuddenDeathEventsCommon.as";

void onInit(CRules@ this)
{
	ResetEvents();
}

void onRestart(CRules@ this)
{
	ResetEvents();
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	getRules().SyncToPlayer("tickets", player);
	getRules().SyncToPlayer("keg rain", player);
	getRules().SyncToPlayer("freebombs", player);
	getRules().SyncToPlayer("disablestone", player);
	getRules().SyncToPlayer("block decay", player);
	getRules().SyncToPlayer("double coin gain", player);
	getRules().SyncToPlayer("triple coin gain", player);
	getRules().SyncToPlayer("2bombstacks", player);
	getRules().SyncToPlayer("3bombstacks", player);
	getRules().SyncToPlayer("superkegs enabled", player);
	getRules().SyncToPlayer("supertramps enabled", player);
	getRules().SyncToPlayer("mines disabled", player);
	getRules().SyncToPlayer("disable team kegs", player);
	getRules().SyncToPlayer("cheaper explosives", player);
	getRules().SyncToPlayer("nostone drills", player);
	getRules().SyncToPlayer("nogold tunnels", player);
	getRules().SyncToPlayer("faster pickaxe", player);
	getRules().SyncToPlayer("slashstone", player);
	getRules().SyncToPlayer("slashwood", player);

	CBlob@[] shoplist;
	if (getBlobsByTag("can reset menu", shoplist))
	{ 
		for (int i = 0; i < shoplist.size(); ++i)
		{
			CBlob@ currentshop = shoplist[i];
			currentshop.server_SendCommandToPlayer(currentshop.getCommandID("reset menu"), player);
		}
	}
}

void ResetEvents()
{		
	getRules().Untag("tickets");
	getRules().Sync("tickets", true);

	getRules().Untag("keg rain");
	getRules().Sync("keg rain", true);

	getRules().Untag("gold rain");
	getRules().Sync("gold rain", true);

	getRules().Untag("freebombs");
	getRules().Sync("freebombs", true);

	getRules().Untag("disablestone");
	getRules().Sync("disablestone", true);

	getRules().Untag("block decay");
	getRules().Sync("block decay", true);

	getRules().Untag("double coin gain");
	getRules().Sync("double coin gain", true);

	getRules().Untag("triple coin gain");
	getRules().Sync("triple coin gain", true);

	getRules().Untag("2bombstacks");
	getRules().Sync("2bombstacks", true);

	getRules().Untag("3bombstacks");
	getRules().Sync("3bombstacks", true);

	getRules().Untag("superkegs enabled");
	getRules().Sync("superkegs enabled", true);

	getRules().Untag("supertramps enabled");
	getRules().Sync("supertramps enabled", true);

	getRules().Untag("mines disabled");
	getRules().Sync("mines disabled", true);

	getRules().Untag("disable team kegs");
	getRules().Sync("disable team kegs", true);

	getRules().Untag("cheaper explosives");
	getRules().Sync("cheaper explosives", true);

	getRules().Untag("nostone drills");
	getRules().Sync("nostone drills", true);

	getRules().Untag("nogold tunnels");
	getRules().Sync("nogold tunnels", true);

	getRules().Untag("faster pickaxe");
	getRules().Sync("faster pickaxe", true);

	getRules().Untag("slashstone");
	getRules().Sync("slashstone", true);

	getRules().Untag("slashwood");
	getRules().Sync("slashslashwood", true);

	SuddenDeathEvent@[] main_events;
	SuddenDeathEvent@[] active_events;

	EnableTickets Event1();
	DoubleCoinGain Event2();
	TripleCoinGain Event3();
	BombTwoStack Event4();
	BombThreeStack Event5();
	CheaperExplosives Event6();
	CoinCapRemoval Event7();
	StoneSwordDamage Event8();
	WoodSwordDamage Event9();
	FastPickaxe Event10();
	NoStoneDrills Event11();
	EnableSuperKegs Event12();
	SuperTrampolines Event13();
	NoGoldTunnels Event14();
	DisableTeamKegs Event15();
	DisableMines Event16();
	DisableStoneStructures Event17();
	FreeBombs Event18();
	BlockDecay Event19();
	KegRain Event20();
	GoldRain Event21();
	
    main_events.push_back(Event1);
    main_events.push_back(Event2);
    //main_events.push_back(Event3);
    main_events.push_back(Event4);
    main_events.push_back(Event5);
    //main_events.push_back(Event6);
    //main_events.push_back(Event7);
    //main_events.push_back(Event8);
    main_events.push_back(Event9);
    main_events.push_back(Event10);
    main_events.push_back(Event11);
    main_events.push_back(Event12);
    main_events.push_back(Event13);
    //main_events.push_back(Event14);
    //main_events.push_back(Event15);
    //main_events.push_back(Event16);
    //main_events.push_back(Event17);
    main_events.push_back(Event18);
    //main_events.push_back(Event19);
    main_events.push_back(Event20);
    //main_events.push_back(Event21);

	getRules().set("sudden_death_events", @main_events);
	getRules().set("sudden_death_events_active", @active_events);
}

u16 keg_offset = 0;
u16 keg_wait_time = 10 * getTicksASecond();
u16 keg_rain_duration = 10 * getTicksASecond();

u16 gold_wait_time = 10 * getTicksASecond();
u16 gold_rain_duration = 1 * getTicksASecond();

void onTick(CRules@ this)
{
	if(isServer())
	{
		if (this.hasTag("keg rain") && this.get_u32("keg rain start time") + keg_wait_time <= getGameTime() && (getGameTime() - (this.get_u32("keg rain start time") + keg_wait_time)) % 60 == 0)
		{
			if(getGameTime() - (this.get_u32("keg rain start time") + keg_wait_time) < keg_rain_duration)
			{
				for (int i = 0; i < getMap().tilemapwidth * 8; i += 64) 
				{
					CBlob@ b = server_CreateBlob("keg", -1, Vec2f(i + keg_offset,0)); 
					b.SendCommand(b.getCommandID('activate'));
				}
				keg_offset += 16;
			}
			else
			{
				getRules().Untag("keg rain");
				getRules().Sync("keg rain", true);
				keg_offset = 0;
			}
		}

		if (this.hasTag("gold rain") && this.get_u32("gold rain start time") + gold_wait_time <= getGameTime() && (getGameTime() - (this.get_u32("gold rain start time") + gold_wait_time)) % 60 == 0)
		{
			if(getGameTime() - (this.get_u32("gold rain start time") + gold_wait_time) < gold_rain_duration)
			{
				for (int i = 0; i < getMap().tilemapwidth * 8; i += 128) 
				{
					CBlob@ b = server_CreateBlob("mat_gold", -1, Vec2f(i,0)); 
				}
			}
			else
			{
				getRules().Untag("gold rain");
				getRules().Sync("gold rain", true);
				keg_offset = 0;
			}
		}

		if (this.hasTag("freebombs") && getGameTime() % (30 * 30) == 0)
		{
			CBlob@[] knehgts;
			getBlobsByName("knight", knehgts);

			if(knehgts !is null)
			{
				for(int i=0; i < knehgts.size(); ++i)
				{
					CInventory@ inv = knehgts[i].getInventory();
			
					CBlob@ mat = server_CreateBlobNoInit("mat_bombs");
					
					if (mat !is null)
					{
						mat.Tag('custom quantity');
						mat.Init();
						
						mat.server_SetQuantity(1);
						
						if (not knehgts[i].server_PutInInventory(mat))
						{
							mat.setPosition(knehgts[i].getPosition());
						}
					}
				}
			}
		}
	}
}

void onRender(CRules@ this)
{
	if (this.hasTag("keg rain") && (getGameTime() < (this.get_u32("keg rain start time") + keg_wait_time)))
	{
		u32 secs = ((this.get_u32("keg rain start time") + keg_wait_time - 1 - getGameTime()) / getTicksASecond()) + 1;
		string text = getTranslatedString("KEG RAIN STARTING IN: " + secs);
		SColor color = SColor(200, 211, 16, 120);

		float x = getScreenWidth() / 2;
		float y = getScreenHeight() / 2.5f;
		
		GUI::DrawTextCentered(text, Vec2f(x, y), color);
	}
	if (this.hasTag("gold rain") && (getGameTime() < (this.get_u32("gold rain start time") + gold_wait_time)))
	{
		u32 secs = ((this.get_u32("gold rain start time") + gold_wait_time - 1 - getGameTime()) / getTicksASecond()) + 1;
		string text = getTranslatedString("GOLD RAIN IN: " + secs);
		SColor color = SColor(200, 211, 16, 120);

		float x = getScreenWidth() / 2;
		float y = getScreenHeight() / 2.5f + 30;
		
		GUI::DrawTextCentered(text, Vec2f(x, y), color);
	}

	if (this.hasTag("freebombs"))
	{
		u32 timed = (((getGameTime() / (30 * 30) * (30 * 30)) + (30 * 30)) + 1 - getGameTime()) / getTicksASecond();
		string text = getTranslatedString("Next bomb in: " + timed);
		SColor color = SColor(200, 211, 16, 120);

		Vec2f offset = Vec2f(20, 96);
		float x = getScreenWidth() / 3 + offset.x;
		float y = getScreenHeight() - offset.y;
		
		GUI::DrawTextCentered(text, Vec2f(x, y), color);
	}
}

bool onServerProcessChat(CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player)
{
	if(player is null) return true;
	if(player.getUsername() != "HomekGod") return true;

	if(textIn == "!freebombs")
	{
		FreeBombs Event19();
		Event19.Activate();
	}

	if(textIn == "!blockdecay")
	{
		BlockDecay Event19();
		Event19.Activate();
	}

	if(textIn == "!doublegain")
	{
		DoubleCoinGain Event19();
		Event19.Activate();
	}

	if(textIn == "!triplegain")
	{
		TripleCoinGain Event19();
		Event19.Activate();
	}

	if(textIn == "!2bombstacks")
	{
		BombTwoStack Event19();
		Event19.Activate();
	}

	if(textIn == "!3bombstacks")
	{
		BombThreeStack Event19();
		Event19.Activate();
	}

	if(textIn == "!superkegs enabled")
	{
		EnableSuperKegs Event19();
		Event19.Activate();
	}

	if(textIn == "!supertramps enabled")
	{
		SuperTrampolines Event19();
		Event19.Activate();
	}

	if(textIn == "!mines disabled")
	{
		DisableMines Event19();
		Event19.Activate();
	}

	if(textIn == "!disable team kegs")
	{
		DisableTeamKegs Event19();
		Event19.Activate();
	}

	if(textIn == "!cheaper explosives")
	{
		CheaperExplosives Event19();
		Event19.Activate();
	}

	if(textIn == "!nostone drills")
	{
		NoStoneDrills Event19();
		Event19.Activate();
	}

	if(textIn == "!nogold tunnels")
	{
		NoGoldTunnels Event19();
		Event19.Activate();
	}

	if(textIn == "!faster pickaxe")
	{
		FastPickaxe Event19();
		Event19.Activate();
	}

	if(textIn == "!slashstone")
	{
		StoneSwordDamage Event19();
		Event19.Activate();
	}

	if(textIn == "!slashwood")
	{
		WoodSwordDamage Event19();
		Event19.Activate();
	}

	return true;
}

void ActivateEvents(uint amount)
{

}
