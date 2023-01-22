// Knight Workshop

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "Costs.as"
#include "CheckSpam.as"

void onInit(CBlob@ this)
{
	this.addCommandID("reset menu");
	this.Tag("can reset menu");
	this.set_TileType("background tile", CMap::tile_wood_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	//INIT COSTS
	InitCosts();

	int shopx = 4;

	if(getRules().hasTag("superkegs enabled")) shopx++;

	// SHOP
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_Vec2f("shop menu size", Vec2f(shopx, 1));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);

	// CLASS
	this.set_Vec2f("class offset", Vec2f(-6, 0));
	this.set_string("required class", "knight");

	u32 minecost = CTFCosts::mine;
	u32 bombcost = CTFCosts::bomb;
	u32 kegcost = CTFCosts::keg;
	u32 superkegcost = 300;

	if(getRules().hasTag("cheaper explosives"))
	{
		minecost *= 0.75f;
		bombcost *= 0.75f;
		kegcost *= 0.75f;
		superkegcost *= 0.75f;
	}

	{
		ShopItem@ s = addShopItem(this, "Bomb", "$bomb$", "mat_bombs", Descriptions::bomb, true);
		AddRequirement(s.requirements, "coin", "", "Coins", bombcost);
		s.quantityLimit = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Water Bomb", "$waterbomb$", "mat_waterbombs", Descriptions::waterbomb, true);
		AddRequirement(s.requirements, "coin", "", "Coins", CTFCosts::waterbomb);
	}
	if(!getRules().hasTag("mines disabled"))
	{
		ShopItem@ s = addShopItem(this, "Mine", "$mine$", "mine", Descriptions::mine, false);
		AddRequirement(s.requirements, "coin", "", "Coins", minecost);
	}
	else
	{
		ShopItem@ s = addShopItem(this, "Mine", "$mine$", "mine", "Mines disabled - sudden death modifier active", false);
		AddRequirement(s.requirements, "coin", "", "Coins", 6969);
	}
	if(getRules().hasTag("disable team kegs"))
	{
		ShopItem@ s = addShopItem(this, "Keg", "$keg$", "keg", Descriptions::keg, false);
		AddRequirement(s.requirements, "coin", "", "Coins", kegcost);
		AddRequirement(s.requirements, "no team side", "", "", 0);
	}	
	else
	{
		ShopItem@ s = addShopItem(this, "Keg", "$keg$", "keg", Descriptions::keg, false);
		AddRequirement(s.requirements, "coin", "", "Coins", kegcost);
	}
	if(getRules().hasTag("superkegs enabled"))
	{
		AddIconToken("$superkeg$", "SuperKeg.png", Vec2f(16, 16), 0);
		{
	       ShopItem@ s = addShopItem(this, "Fat Keg", "$superkeg$", "superkeg", "Will give the enemy team conniptions", false);
	       AddRequirement(s.requirements, "coin", "", "Coins", superkegcost);
	    }
	}
	/*	AddIconToken("$superkeg$", "SuperKeg.png", Vec2f(16, 16), 0);
	{
       ShopItem@ s = addShopItem(this, "Fat Keg", "$superkeg$", "superkeg", "Will give the enemy team conniptions", false);
       AddRequirement(s.requirements, "coin", "", "Coins", 300);
    }*/
    /*	AddIconToken("$teleportbomb$", "TeleportBomb.png", Vec2f(16, 16), 0);
	{
       ShopItem@ s = addShopItem(this, "Teleport Bomb", "$teleportbomb$", "mat_teleportbombs", "Teleports you to the place it explodes in", true);
       AddRequirement(s.requirements, "coin", "", "Coins", 50);
    }*/
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
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
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
}