// BuilderShop.as

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"
// mat dropping
#include "RulesCore.as";
#include "CTF_Structs.as";
#include "CTF_GiveSpawnItems.as";

void onInit(CBlob@ this)
{
	this.addCommandID("reset menu");
	this.Tag("can reset menu");
	InitCosts(); //read from cfg

	AddIconToken("$_buildershop_filled_bucket$", "Bucket.png", Vec2f(16, 16), 1);

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.addCommandID("drop mats");

	int shopy = 4;

	if(getRules().hasTag("supertramps enabled")) shopy++;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(4, shopy));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "builder");

	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", Descriptions::lantern, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::lantern_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", Descriptions::bucket, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::bucket_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Filled Bucket", "$_buildershop_filled_bucket$", "filled_bucket", Descriptions::filled_bucket, false);
		s.spawnNothing = true;
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::filled_bucket);
	}
	{
		ShopItem@ s = addShopItem(this, "Sponge", "$sponge$", "sponge", Descriptions::sponge, false);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::sponge);
	}
	{
		ShopItem@ s = addShopItem(this, "Boulder", "$boulder$", "boulder", Descriptions::boulder, false);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 35);
	}
	{
		ShopItem@ s = addShopItem(this, "Trampoline", "$trampoline$", "trampoline", Descriptions::trampoline, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 6969/*CTFCosts::trampoline_wood*/);
	}

	if(getRules().hasTag("nostone drills"))
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", Descriptions::drill, false);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
	}
	else
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", Descriptions::drill, false);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::drill_stone);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
	}

	{
		ShopItem@ s = addShopItem(this, "Saw", "$saw$", "saw", Descriptions::saw, false);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::saw_wood);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", CTFCosts::saw_stone);
	}
	{
		ShopItem@ s = addShopItem(this, "Crate (wood)", "$crate$", "crate", Descriptions::crate, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", CTFCosts::crate_wood);
	}
	{
		ShopItem@ s = addShopItem(this, "Crate (coins)", "$crate$", "crate", Descriptions::crate, false);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::crate);
	}
	if(getRules().hasTag("supertramps enabled"))
	{
		AddIconToken("$supertrampoline$", "SuperTrampoline.png", Vec2f(32, 16), 3);
		{
	       ShopItem@ s = addShopItem(this, "Super Trampoline", "$supertrampoline$", "supertrampoline", "150% launch force, doesn't get damage for using, and doesn't get fall damage.", false);
	       AddRequirement(s.requirements, "coin", "", "Coins", 150);
	    }
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getConfig() == this.get_string("required class"))
	{
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(6, 0));
	}

	if (!getRules().isWarmup() && caller.getConfig() != this.get_string("required class"))
	{
		AddIconToken("$drop_mats$", "InteractionIcons.png", Vec2f(32, 32), 15);

		Vec2f pagchomp = Vec2f_zero;
		pagchomp.y = Vec2f_zero.y - 5;

		CBitStream params;
		params.write_u16(caller.getNetworkID());

		CButton@ dropmats = caller.CreateGenericButton("$drop_mats$", pagchomp, this, this.getCommandID("drop mats"), "Drop Mats", params);

		CShape@ shape = this.getShape();

		if(shape !is null)
		{
			dropmats.enableRadius = Maths::Max(this.getRadius(), (shape.getWidth() + shape.getHeight()) / 2) * 2;
		}
	}
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
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
	if (cmd == this.getCommandID("reset menu"))
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
}
