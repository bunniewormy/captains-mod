#include "Requirements.as"
#include "ShopCommon.as"

shared class Icon
{
	string texture;
	int frame;
	int x;
	int y;

	Icon(string a, int b, int c, int d)
	{
		texture = a;
		frame = b;
		x = c;
		y = d;
	}
}

shared class SuddenDeathEvent
{
	string name;
	string description;
	bool onetimeonly = false;
	Icon eventicon;
	void Activate() {}
};

// Tickets disabled again in SuddenDeath.as
shared class EnableTickets : SuddenDeathEvent
{
	EnableTickets()
	{
		name = "Enable tickets";
		description = "Enables tickets - limited amount of lives, 150 for each team. \n A team is no longer able to respawn if it runs out of tickets.";
		eventicon = Icon("SuddenDeathIcons.png", 0, 32, 32);
		
	}

	void Activate()
	{
		CRules@ rules = getRules();
		rules.Tag("tickets");
		rules.Sync("tickets", true);
		rules.set_s16("redTickets", 150);
		rules.set_s16("blueTickets", 150);
		rules.Sync("redTickets", true);
		rules.Sync("blueTickets", true);
	}
}

// CTF_Trading.as
shared class DoubleCoinGain : SuddenDeathEvent
{
	DoubleCoinGain()
	{
		name = "Double coin gain";
		description = "Doubles all coins you get from anything - combat, building, etc.";
		eventicon = Icon("SuddenDeathIcons.png", 1, 32, 32);
		
	}

	void Activate()
	{
		CRules@ rules = getRules();
		rules.Tag("double coin gain");
		rules.Sync("double coin gain", true);
	}
}

// CTF_Trading.as
shared class TripleCoinGain : SuddenDeathEvent
{
	TripleCoinGain()
	{
		name = "Triple coin gain";
		description = "Triple all coins you get from anything - combat, building, etc.";
		eventicon = Icon("SuddenDeathIcons.png", 2, 32, 32);
		
	}

	void Activate()
	{
		CRules@ rules = getRules();
		rules.Tag("triple coin gain");
		rules.Sync("triple coin gain", true);
	}
}

// MaterialBomb.as;
shared class BombTwoStack : SuddenDeathEvent
{
	BombTwoStack()
	{
		name = "Bombs stack to two";
		description = "Changes stack size of bombs to 2";
		eventicon = Icon("SuddenDeathIcons.png", 3, 32, 32);
		
	}

	void Activate()
	{
		CRules@ rules = getRules();
		rules.Tag("2bombstacks");
		rules.Sync("2bombstacks", true);

		if(!isServer()) return;

		CBlob@[] list;

		if(getBlobsByName("mat_bombs", list))
		{
			for (int i = 0; i < list.size(); ++i)
			{
				if(list[i].maxQuantity <= 2)
				list[i].maxQuantity = 2; 
			}
		}
	}
}

// MaterialBomb.as;
shared class BombThreeStack : SuddenDeathEvent
{
	BombThreeStack()
	{
		name = "Bombs stack to three";
		description = "Changes stack size of bombs to 3";
		eventicon = Icon("SuddenDeathIcons.png", 4, 32, 32);
		
	}

	void Activate()
	{
		CRules@ rules = getRules();
		rules.Tag("3bombstacks");
		rules.Sync("3bombstacks", true);

		if(!isServer()) return;

		CBlob@[] list;

		if(getBlobsByName("mat_bombs", list))
		{
			for (int i = 0; i < list.size(); ++i)
			{
				if(list[i].maxQuantity <= 3)
				list[i].maxQuantity = 3; 
			}
		}
	}
}

// modify ShopCommon.as, Requirements.as and item prices in KnightShop.as, ArcherShop.as
// or maybe just add a ChangeShopItem function into shopcommon and run price changing here in Activate
shared class CheaperExplosives : SuddenDeathEvent
{
	CheaperExplosives()
	{
		name = "Cheaper explosives";
		description = "Reduce cost of bombs, bomb arrows and kegs by 25% of their original price";
		eventicon = Icon("SuddenDeathIcons.png", 5, 32, 32);
		
	}

	void Activate()
	{
		CRules@ rules = getRules();
		rules.Tag("cheaper explosives");
		rules.Sync("cheaper explosives", true);

		if(!isServer()) return;

		CBlob@[] lista;
		if(getBlobsByName("knightshop", lista))
		{
			for (int i = 0; i < lista.size(); ++i)
			{
				CBlob@ currentshop = lista[i];
				currentshop.SendCommand(currentshop.getCommandID("reset menu"));
			}
		}

		CBlob@[] listb;
		if(getBlobsByName("archershop", listb))
		{
			for (int i = 0; i < listb.size(); ++i)
			{
				CBlob@ currentshop = listb[i];
				currentshop.SendCommand(currentshop.getCommandID("reset menu"));
			}
		}

		CBlob@[] listc;
		if(getBlobsByName("midshop5", listc))
		{
			for (int i = 0; i < listc.size(); ++i)
			{
				CBlob@ currentshop = listc[i];
				currentshop.SendCommand(currentshop.getCommandID("reset bmenu"));
			}
		}

		CBlob@[] listd;
		if(getBlobsByName("midshop6", listd))
		{
			for (int i = 0; i < listd.size(); ++i)
			{
				CBlob@ currentshop = listd[i];
				currentshop.SendCommand(currentshop.getCommandID("reset bmenu"));
			}
		}

	}
}

// Coin cap added back in CoinCap.as
shared class CoinCapRemoval : SuddenDeathEvent
{
	CoinCapRemoval()
	{
		name = "Coin cap removal";
		description = "Removes the coin cap of 600 coins";
		eventicon = Icon("SuddenDeathIcons.png", 6, 32, 32);
		
	}

	void Activate()
	{
		getRules().set_u16("coincap", 20000);
		getRules().Sync("coincap", true);
	}
}

// KnightLogic.as
shared class StoneSwordDamage : SuddenDeathEvent
{
	StoneSwordDamage()
	{
		name = "Enable sword damage against stone";
		description = "Enables doing damage to stone blocks and stone doors";
		eventicon = Icon("SuddenDeathIcons.png", 7, 32, 32);
	}

	void Activate()
	{
		CRules@ rules = getRules();
		rules.Tag("slashstone");
		rules.Sync("slashstone", true);
	}
}

// KnightLogic.as
shared class WoodSwordDamage : SuddenDeathEvent
{
	WoodSwordDamage()
	{
		name = "Increase sword damage against wood";
		description = "Increases (doubles) the damage done to wooden blocks, doors, platforms by swords";
		eventicon = Icon("SuddenDeathIcons.png", 8, 32, 32);
		
	}

	void Activate()
	{
		CRules@ rules = getRules();
		rules.Tag("slashwood");
		rules.Sync("slashwood", true);
	}
}

// BuilderAnim.as, BuilderLogic.as
shared class FastPickaxe : SuddenDeathEvent
{
	FastPickaxe()
	{
		name = "Faster pickaxe";
		description = "Increases the speed at which builder pickaxe hits player-built blocks";
		eventicon = Icon("SuddenDeathIcons.png", 9, 32, 32);
		
	}

	void Activate()
	{
		CRules@ rules = getRules();
		rules.Tag("faster pickaxe");
		rules.Sync("faster pickaxe", true);
	}
}

// BuilderShop.as, ShopCommon.as
shared class NoStoneDrills : SuddenDeathEvent
{
	NoStoneDrills()
	{
		name = "Remove drill stone cost";
		description = "Removes the stone cost from drills in builder shop";
		eventicon = Icon("SuddenDeathIcons.png", 10, 32, 32);
		
	}

	void Activate()
	{
		CRules@ rules = getRules();
		rules.Tag("nostone drills");
		rules.Sync("nostone drills", true);

		if(!isServer()) return;

		CBlob@[] list;

		if(getBlobsByName("buildershop", list))
		{
			for (int i = 0; i < list.size(); ++i)
			{
				CBlob@ currentshop = list[i];
				currentshop.SendCommand(currentshop.getCommandID("reset menu"));
			}
		}
	}
}

// KnightShop.as, Midshop.as, maybe some new function in ShopCommon.as will be needed
shared class EnableSuperKegs : SuddenDeathEvent
{
	EnableSuperKegs()
	{
		name = "Enable Super Kegs";
		description = "Adds Super Kegs (240 coins) to knight shop and the mid shop (300 coins)";
		eventicon = Icon("SuddenDeathIcons.png", 11, 32, 32);
		
	}

	void Activate()
	{
		CRules@ rules = getRules();
		rules.Tag("superkegs enabled");
		rules.Sync("superkegs enabled", true);

		if(!isServer()) return;

		CBlob@[] list;

		if(getBlobsByName("knightshop", list))
		{
			for (int i = 0; i < list.size(); ++i)
			{
				CBlob@ currentshop = list[i];
				currentshop.SendCommand(currentshop.getCommandID("reset menu"));
			}
		}
	}
}

// BuilderShop.as, SuperTrampoline.as
shared class SuperTrampolines : SuddenDeathEvent
{
	SuperTrampolines()
	{
		name = "Add super trampolines";
		description = "Adds 150-coin trampolines with a higher launch force and no decay when being used to the builder shop";
		eventicon = Icon("SuddenDeathIcons.png", 12, 32, 32);
		
	}

	void Activate()
	{
		CRules@ rules = getRules();
		rules.Tag("supertramps enabled");
		rules.Sync("supertramps enabled", true);

		if(!isServer()) return;

		CBlob@[] list;

		if(getBlobsByName("buildershop", list))
		{
			for (int i = 0; i < list.size(); ++i)
			{
				CBlob@ currentshop = list[i];
				currentshop.SendCommand(currentshop.getCommandID("reset menu"));
			}
		}
	}
}

// Tunnel.as, Building.as?
shared class NoGoldTunnels : SuddenDeathEvent
{
	NoGoldTunnels()
	{
		name = "Remove gold cost from tunnels";
		description = "Removes gold cost from tunnels.";
		eventicon = Icon("SuddenDeathIcons.png", 13, 32, 32);
		
	}

	void Activate()
	{
		CRules@ rules = getRules();
		rules.Tag("nogold tunnels");
		rules.Sync("nogold tunnels", true);

		if(!isServer()) return;

		CBlob@[] list;

		if(getBlobsByName("building", list))
		{
			for (int i = 0; i < list.size(); ++i)
			{
				CBlob@ currentshop = list[i];
				currentshop.SendCommand(currentshop.getCommandID("reset bmenu"));
			}
		}
	}
}

// Knightshop.as
shared class DisableTeamKegs : SuddenDeathEvent
{
	DisableTeamKegs()
	{
		name = "Disable buying kegs in your team's half of the map";
		description = "Disables buying kegs in your team's half of the map. \nYou can only buy kegs from the mid shop or from knight shops beyond middle of the map.";
		eventicon = Icon("SuddenDeathIcons.png", 14, 32, 32);
		
	}

	void Activate()
	{
		CRules@ rules = getRules();
		rules.Tag("disable team kegs");
		rules.Sync("disable team kegs", true);

		if(!isServer()) return;

		CBlob@[] list;

		if(getBlobsByName("knightshop", list))
		{
			for (int i = 0; i < list.size(); ++i)
			{
				CBlob@ currentshop = list[i];
				currentshop.SendCommand(currentshop.getCommandID("reset menu"));
			}
		}
	}
}

// KnightShop.as, Midshop.as
shared class DisableMines : SuddenDeathEvent
{
	DisableMines()
	{
		name = "Disable mines";
		description = "Removes mines from the knight shop and midshop.";
		eventicon = Icon("SuddenDeathIcons.png", 15, 32, 32);
		
	}

	void Activate()
	{
		CRules@ rules = getRules();
		rules.Tag("mines disabled");
		rules.Sync("mines disabled", true);

		if(!isServer()) return;

		CBlob@[] list;

		if(getBlobsByName("mine", list))
		{
			for (int i = 0; i < list.size(); ++i)
			{
				CBlob@ currentmine = list[i];
				currentmine.server_Die();
			}
		}
		if(getBlobsByName("knightshop", list))
		{
			for (int i = 0; i < list.size(); ++i)
			{
				CBlob@ currentshop = list[i];
				currentshop.SendCommand(currentshop.getCommandID("reset menu"));
			}
		}
	}
}

// CommonBuilderBlocks.as? BuilderLogic.as? shitty hack would just be to make the cost of them 3000 lol
shared class DisableStoneStructures : SuddenDeathEvent
{
	DisableStoneStructures()
	{
		name = "Disable stone blocks and doors";
		description = "Removes the ability to build stone blocks and stone doors from builders";
		eventicon = Icon("SuddenDeathIcons.png", 16, 32, 32);
		
	}

	void Activate()
	{
		getRules().Tag("disablestone");
		getRules().Sync("disablestone", true);
	}
}

// SuddenDeath.as
shared class FreeBombs : SuddenDeathEvent
{
	FreeBombs()
	{
		name = "Free bombs every 30 seconds";
		description = "Every knight on the map, regardless of where they are, will get a free bomb every 30 seconds.";
		eventicon = Icon("SuddenDeathIcons.png", 17, 32, 32);
		
		
	}

	void Activate()
	{
		getRules().Tag("freebombs");
		getRules().Sync("freebombs", true);
	}
}

// SuddenDeath.as
shared class BlockDecay : SuddenDeathEvent
{
	BlockDecay()
	{
		name = "Enable block decay";
		description = "20% of player-built blocks on map on each side will get 1 pickaxe hit every 2 minutes";
		eventicon = Icon("SuddenDeathIcons.png", 18, 32, 32);
		
	}

	void Activate()
	{
		getRules().Tag("block decay");
		getRules().Sync("block decay", true);

		CMap@ map = getMap();
		if (map !is null)
		{
			Vec2f[] player_tiles;
			for (u32 x = 0; x < map.tilemapwidth; x++)
			{
				for (u32 y = 0; y < map.tilemapheight; y++)
				{
					Vec2f coords(x * map.tilesize, y * map.tilesize);

					Tile tile = map.getTile(coords);

					bool isbuilt = false;

					if (map.isTileWood(tile.type) || // wood tile
						tile.type == CMap::tile_wood_back || // wood backwall
						tile.type == 207 || // wood backwall damaged
						map.isTileCastle(tile.type) || // castle block
						tile.type == CMap::tile_castle_back || // castle backwall
						tile.type == 76 || // castle backwall damaged
						tile.type == 77 || // castle backwall damaged
						tile.type == 78 || // castle backwall damaged
						tile.type == 79 || // castle backwall damaged
						tile.type == CMap::tile_castle_back_moss) // castle mossbackwall
					{
						isbuilt = true;
					}

					if (isbuilt)
					{
						player_tiles.push_back(coords);
					}
				}
			}
			map.set("player_tiles", @player_tiles);

			if (!map.hasScript("BlockDecay.as")) map.AddScript("BlockDecay.as");
		}
	}
}

// SuddenDeath.as
shared class KegRain : SuddenDeathEvent
{
	KegRain()
	{
		name = "Keg rain";
		description = "Rains explosive kegs from the sky all around the map for a few seconds";
		onetimeonly = true;
		eventicon = Icon("SuddenDeathIcons.png", 19, 32, 32);
		
	}

	void Activate()
	{
		getRules().Tag("keg rain");
		getRules().set_u32("keg rain start time", getGameTime());
	}
}

// SuddenDeath.as
shared class GoldRain : SuddenDeathEvent
{
	GoldRain()
	{
		name = "Gold rain";
		description = "Spawns gold all around the map";
		onetimeonly = true;
		eventicon = Icon("SuddenDeathIcons.png", 20, 32, 32);
		
	}

	void Activate()
	{
		getRules().Tag("gold rain");
		getRules().set_u32("gold rain start time", getGameTime());
	}
}