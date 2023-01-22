//not server only so the client also gets the game event setup stuff

#include "GameplayEvents.as"
#include "ZonesCommon.as"

const f32 killstreakFactor = 1.2f;

const int coinsOnDamageAdd = 8;
const int coinsOnKillAdd = 15;

const int coinsOnDeathLosePercent = 10;
const int coinsOnTKLose = 0;

const int coinsOnRestartAdd = 50;
const bool keepCoinsOnRestart = false;

const int coinsOnHitSiege = 8;
const int coinsOnKillSiege = 30;

const int coinsOnCapFlag = 100;

const int coinsOnBuild = 3;
const int coinsOnBuildWood = 1;
const int coinsOnBuildWorkshop = 10;

const int warmupFactor = 3;

string[] names;

bool SetMaterials(CBlob@ blob,  const string &in name, const int quantity, bool drop = false)
{
	CBlob@ mat = server_CreateBlobNoInit(name);
	
	if (mat !is null)
	{
		mat.Tag('custom quantity');
		mat.Init();
		
		mat.server_SetQuantity(quantity);
		
		mat.setPosition(blob.getPosition());
	}
	
	return true;
}

float getMultiplier()
{
	float multiplier = 1.0f;
	if(getRules().hasTag("double coin gain")) multiplier = 2.0f;
	if(getRules().hasTag("triple coin gain")) multiplier = 3.0f;

	return multiplier;
}

float getZoneModifierGain(CPlayer@ p)
{
	string zone = getPlayersZone(p);

	if(getRules().getCurrentState() == WARMUP || getRules().getCurrentState() == INTERMISSION) return 1.00f;

	if(zone == "a") return 0.90f;
	if(zone == "b") return 1.00f;
	if(zone == "c") return 1.20f;

	return 1.00f;
}

float getZoneModifierLoss(CPlayer@ p)
{
	string zone = getPlayersZone(p);

	if(zone == "a") return 0.15f;
	if(zone == "b") return 0.125f;
	if(zone == "c") return 0.10f;

	return 0.10f;
}

void GiveRestartCoins(CPlayer@ p)
{
	if (keepCoinsOnRestart)
		p.server_setCoins(p.getCoins() + coinsOnRestartAdd);
	else
		p.server_setCoins(coinsOnRestartAdd);
}

void GiveRestartCoinsIfNeeded(CPlayer@ player)
{
	const string s = player.getUsername();
	for (uint i = 0; i < names.length; ++i)
	{
		if (names[i] == s)
		{
			return;
		}
	}

	names.push_back(s);
	GiveRestartCoins(player);
}

//extra coins on start to prevent stagnant round start
void Reset(CRules@ this)
{
	if (!getNet().isServer())
		return;

	names.clear();

	uint count = getPlayerCount();
	for (uint p_step = 0; p_step < count; ++p_step)
	{
		CPlayer@ p = getPlayer(p_step);
		GiveRestartCoins(p);
		names.push_back(p.getUsername());
	}
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
}

//also given when plugging player -> on first spawn
void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
	if (!getNet().isServer())
		return;

	if (player !is null)
	{
		GiveRestartCoinsIfNeeded(player);
	}
}

//
// give coins for killing

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData)
{
	if (!getNet().isServer())
		return;

	if (victim !is null)
	{
		if (killer !is null)
		{
			if (killer !is victim && killer.getTeamNum() != victim.getTeamNum())
			{
				killer.server_setCoins(killer.getCoins() + (coinsOnKillAdd * Maths::Pow(killstreakFactor, killer.get_u8("killstreak"))) * getZoneModifierGain(killer) * getMultiplier());
			}
		}
		if (!this.isWarmup())	//only reduce coins if the round is on.
		{
			s32 lost = victim.getCoins() * getZoneModifierLoss(victim);

			victim.server_setCoins(victim.getCoins() - lost);

			//drop coins
			CBlob@ blob = victim.getBlob();
			if (blob !is null)
				server_DropCoins(blob.getPosition(), XORRandom(lost));

			CBlob@[] blist;

			int team;

			if(victim.getBlob().getTeamNum() == 0) team = 1;
			else team = 0;
				
			if (getBlobsByName("tent", blist))
			{
				for(uint step=0; step<blist.length; ++step)
				{
					if(blist[step].getTeamNum() == team)
					{
						SetMaterials(blist[step], "mat_wood", 30, true);
						SetMaterials(blist[step], "mat_stone", 6, true); 
						break;
					}
				}
			}

		}
	}
}

// give coins for damage

f32 onPlayerTakeDamage(CRules@ this, CPlayer@ victim, CPlayer@ attacker, f32 DamageScale)
{
	if (!getNet().isServer())
		return DamageScale;

	if (attacker !is null && attacker !is victim && attacker.getTeamNum() != victim.getTeamNum())
	{
        CBlob@ v = victim.getBlob();
        f32 health = 0.0f;
        if(v !is null)
            health = v.getHealth();
        f32 dmg = DamageScale;
        dmg = Maths::Min(health, dmg);

		attacker.server_setCoins(attacker.getCoins() + (dmg * coinsOnDamageAdd / this.attackdamage_modifier) * getZoneModifierGain(attacker) * getMultiplier());
	}

	return DamageScale;
}

// coins for various game events
void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	//only important on server
	if (!getNet().isServer())
		return;

	if (cmd == getGameplayEventID(this))
	{
		GameplayEvent g(params);

		CPlayer@ p = g.getPlayer();
		if (p !is null)
		{
			u32 coins = 0;

			bool frombuilding = false;

			switch (g.getType())
			{
				case GE_built_block:

				{
					frombuilding = true;
					g.params.ResetBitIndex();
					u16 tile = g.params.read_u16();
					if (tile == CMap::tile_castle)
					{
						coins = coinsOnBuild * getZoneModifierGain(p) * getMultiplier();
					}
					else if (tile == CMap::tile_wood)
					{
						coins = coinsOnBuildWood * getZoneModifierGain(p) * getMultiplier();
					}
				}

				break;

				case GE_built_blob:

				{
					frombuilding = true;
					g.params.ResetBitIndex();
					string name = g.params.read_string();

					if (name == "stone_door" ||
					        name == "trap_block" ||
					        name == "spikes")
					{
						coins = coinsOnBuild * getZoneModifierGain(p) * getMultiplier();
					}
					else if (name == "wooden_platform" ||
								name == "wooden_door")
					{
						coins = coinsOnBuildWood * getZoneModifierGain(p) * getMultiplier();
					}
					else if (name == "building")
					{
						coins = coinsOnBuildWorkshop * getZoneModifierGain(p) * getMultiplier();
					}
				}

				break;

				case GE_hit_vehicle:

				{
					g.params.ResetBitIndex();
					f32 damage = g.params.read_f32();
					coins = (coinsOnHitSiege * damage) * getZoneModifierGain(p) * getMultiplier();
				}

				break;

				case GE_kill_vehicle:
					coins = coinsOnKillSiege * getZoneModifierGain(p) * getMultiplier();
					break;

				case GE_captured_flag:
					coins = coinsOnCapFlag * getMultiplier();
					break;
			}

			if (coins > 0)
			{
				if (this.isWarmup())
					coins /= warmupFactor;

				if (p.getCoins() >= 50 && frombuilding)
				{
					return;
				}

				p.server_setCoins(p.getCoins() + coins);
			}
		}
	}
}
