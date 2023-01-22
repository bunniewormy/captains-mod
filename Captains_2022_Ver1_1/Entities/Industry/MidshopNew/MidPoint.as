// Vehicle Workshop

#include "GenericButtonCommon.as"
#include "StandardRespawnCommand.as"
#include "StandardControlsCommon.as"
#include "TunnelCommon.as"
#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
#include "TeamIconToken.as"

#include "RulesCore.as";
#include "CTF_Structs.as";
#include "CTF_GiveSpawnItems.as";

u8 respawn_time = 30 * 5; // 5 seconds
u8 respawn_immunity_time = 30 * 1; // 1 second

void onInit(CBlob@ this)
{
	this.addCommandID("reset menu");
	this.Tag("can reset menu");
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	AddIconToken("$_buildershop_filled_bucket$", "Bucket.png", Vec2f(16, 16), 1);
	AddIconToken("$quarters_burger$", "Quarters.png", Vec2f(24, 24), 9);

	//INIT COSTS
	InitCosts();

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(-6, -5));
	this.set_Vec2f("shop menu size", Vec2f(6, 4));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	this.CreateRespawnPoint("midpoint", Vec2f(0.0f, -4.0f));

	this.addCommandID("drop mats");

	InitRespawnCommand(this);
	InitClasses(this);

	this.Tag("respawn");
	this.Tag("change class drop inventory");
	this.Tag("travel tunnel");
	this.Tag("teamlocked tunnel");
	this.Tag("ignore raid");
	this.Tag("builder always hit");

	this.set_u8("additional respawn time", respawn_time);
	this.set_u8("custom respawn immunity", respawn_immunity_time); 

	this.set_Vec2f("travel button pos", Vec2f(0, 6));
	this.set_Vec2f("travel offset", Vec2f(0, 0));

	CSprite@ sprite = this.getSprite();

	CSpriteLayer@ planks = sprite.addSpriteLayer("planks", "Outpost.png", 16, 16);
	if (planks !is null)
	{
		Animation@ anim = planks.addAnimation("default", 0, false);
		anim.AddFrame(40);
		planks.SetRelativeZ(10.0f);
		planks.SetOffset(Vec2f(0.0f, 11.0f));
	}

	u32 minecost = CTFCosts::mine;
	u32 bombcost = CTFCosts::bomb;
	u32 kegcost = CTFCosts::keg;
	u32 superkegcost = 300;
	u32 bombarrowcost = 40;

	if(getRules().hasTag("cheaper explosives"))
	{
		minecost *= 0.75f;
		bombcost *= 0.75f;
		kegcost *= 0.75f;
		superkegcost *= 0.75f;
		bombarrowcost *= 0.75f;
	}

	int team_num = this.getTeamNum();
	{
		ShopItem@ s = addShopItem(this, "Bomb", "$bomb$", "mat_bombs", Descriptions::bomb, true);
		AddRequirement(s.requirements, "coin", "", "Coins", bombcost * 1.25);
		s.quantityLimit = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Water Bomb", "$waterbomb$", "mat_waterbombs", Descriptions::waterbomb, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::waterbomb * 1.25 );
	}
	{
		ShopItem@ s = addShopItem(this, "Mine", "$mine$", "mine", Descriptions::mine, false);
		AddRequirement(s.requirements, "coin", "", "Coins", minecost * 1.25);
	}
	{
		ShopItem@ s = addShopItem(this, "Keg", "$keg$", "keg", Descriptions::keg, false);
		AddRequirement(s.requirements, "coin", "", "Coins", kegcost * 1.25);
	}	
	{
		ShopItem@ s = addShopItem(this, "Burger - Full Health", "$quarters_burger$", "food", Descriptions::burger, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::burger * 1.25);
	}
	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", Descriptions::lantern, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::lantern_wood * 1.25);
	}
	{
		ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", Descriptions::bucket, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::bucket_wood * 1.25);
	}
	{
		ShopItem@ s = addShopItem(this, "Filled Bucket", "$_buildershop_filled_bucket$", "filled_bucket", Descriptions::filled_bucket, false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::filled_bucket * 1.25);
	}
	{
		ShopItem@ s = addShopItem(this, "Sponge", "$sponge$", "sponge", Descriptions::sponge, false);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::sponge * 1.25);
	}
	{
		ShopItem@ s = addShopItem(this, "Boulder", "$boulder$", "boulder", Descriptions::boulder, false);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::boulder_stone * 1.25);
	}
	{
		ShopItem@ s = addShopItem(this, "Arrows", "$mat_arrows$", "mat_arrows", Descriptions::arrows, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::arrows * 1.25);
	}
	{
		ShopItem@ s = addShopItem(this, "Water Arrows", "$mat_waterarrows$", "mat_waterarrows", Descriptions::waterarrows, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::waterarrows * 1.25);
	}
	{
		ShopItem@ s = addShopItem(this, "Fire Arrows", "$mat_firearrows$", "mat_firearrows", Descriptions::firearrows, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::firearrows * 1.25);
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb Arrows", "$mat_bombarrows$", "mat_bombarrows", Descriptions::bombarrows, true);
		AddRequirement(s.requirements, "coin", "", "Coins", bombarrowcost * 1.25);
	}
	{
		ShopItem@ s = addShopItem(this, "Heal Arrows", "$mat_healarrows$", "mat_healarrows", "Makes a splash which heals teammates to full health.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", 25 * 1.25);
	}
	{
		ShopItem@ s = addShopItem(this, "Trampoline", getTeamIcon("trampoline", "Trampoline.png", team_num, Vec2f(32, 16), 3), "trampoline", Descriptions::trampoline, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::trampoline_wood * 1.25);
	}
	{
		ShopItem@ s = addShopItem(this, "Saw", getTeamIcon("saw", "VehicleIcons.png", team_num, Vec2f(32, 32), 3), "saw", Descriptions::saw, false);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::saw_wood * 1.25);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::saw_stone * 1.25);
	}
	{
		ShopItem@ s = addShopItem(this, "Crate (wood)", getTeamIcon("crate", "Crate.png", team_num, Vec2f(32, 16), 5), "crate", Descriptions::crate, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::crate_wood * 1.25);
	}
	{
		ShopItem@ s = addShopItem(this, "Crate (coins)", getTeamIcon("crate", "Crate.png", team_num, Vec2f(32, 16), 5), "crate", Descriptions::crate, false);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::crate * 1.25);
	}
}

void onTick(CBlob@ this)
{
	CBlob@ blob = getLocalPlayerBlob();

	if (blob !is null && blob.isMyPlayer())
	{
		if (this.isOverlapping(blob) && getGameTime() > getCTFTimerBuilder(getRules(), blob.getPlayer()))
		{
			CBitStream params;
			params.write_u16(blob.getNetworkID());

			this.SendCommand(this.getCommandID("drop mats"), params);
		}
	}
}

void onTick(CSprite@ this)
{
	CSpriteLayer@ planks = this.getSpriteLayer("planks");
	if (planks is null) return;
	CBlob@[] list;

	planks.SetVisible(!getTunnels(this.getBlob(), list));
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	this.set_Vec2f("shop offset", Vec2f(-10, -10));
	this.set_bool("shop available", this.isOverlapping(caller));

	if (canChangeClass(this, caller))
	{
		caller.CreateGenericButton("$change_class$", Vec2f(5, -5), this, buildSpawnMenu, getTranslatedString("Swap Class"));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("drop mats") && isServer())
	{
		RulesCore@ core;

		CRules@ rules = getRules();

		rules.get("core", @core);

		if(core !is null)
		{
			u16 id = params.read_u16();

			CBlob@ b = getBlobByNetworkID(id);

			if(b !is null)
			{
				if (!this.isOverlapping(b)) return;
				
				CPlayer@ p = b.getPlayer();

				if(p !is null)
				{
					p.Tag("dropping_mats");

					doGiveSpawnMats(rules, p, b);
				}
			}
		}
	}
	else if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");

		if(!getNet().isServer()) return; /////////////////////// server only past here

		u16 caller, item;
		if (!params.saferead_netid(caller) || !params.saferead_netid(item))
		{
			return;
		}
		string name = params.read_string();
		{
			CBlob@ callerBlob = getBlobByNetworkID(caller);
			if (callerBlob is null)
			{
				return;
			}

			if (name == "filled_bucket")
			{
				CBlob@ b = server_CreateBlobNoInit("bucket");
				b.setPosition(callerBlob.getPosition());
				b.server_setTeamNum(callerBlob.getTeamNum());
				b.Tag("_start_filled");
				b.Init();
				callerBlob.server_Pickup(b);
			}
		}
	}
	else if (cmd == this.getCommandID("reset menu"))
	{
		if (this.exists("shop array"))
		{
			ShopItem[] @items;
			this.get("shop array", @items);

			items.clear();
			this.set("shop array", @items);
		}
		onInit(this);
	}
	else
	{
		onRespawnCommand(this, cmd, params);
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return false;
}
