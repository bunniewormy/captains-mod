// Vehicle Workshop

#include "GenericButtonCommon.as"
#include "StandardRespawnCommand.as"
#include "StandardControlsCommon.as"
#include "TunnelCommon.as"

#include "RulesCore.as";
#include "CTF_Structs.as";
#include "CTF_GiveSpawnItems.as";

u8 respawn_time = 30 * 10; // 10 seconds
u8 respawn_immunity_time = 30 * 2; // 2 seconds

const f32 BASE_RADIUS = 200.0f;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.CreateRespawnPoint("controlpoint", Vec2f(0.0f, -4.0f));

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

	this.set_Vec2f("travel button pos", Vec2f(-6, 0));
	this.set_Vec2f("travel offset", Vec2f(-10, 0));

	CSprite@ sprite = this.getSprite();

	CSpriteLayer@ planks = sprite.addSpriteLayer("planks", "Outpost.png", 16, 16);
	if (planks !is null)
	{
		Animation@ anim = planks.addAnimation("default", 0, false);
		anim.AddFrame(40);
		planks.SetRelativeZ(10.0f);
		planks.SetOffset(Vec2f(9.0f, 4.0f));
	}

	Vec2f pos = this.getPosition();

	// right side of map 
	if(pos.x / 8 > getMap().tilemapwidth / 2)
	{
		this.SetFacingLeft(true);
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

	if (canChangeClass(this, caller))
	{
		caller.CreateGenericButton("$change_class$", Vec2f(6, 0), this, buildSpawnMenu, getTranslatedString("Swap Class"));
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

					doGiveSpawnMats(rules, p, b, "controlpoint");
				}
			}
		}
	}

	else
	{
		onRespawnCommand(this, cmd, params);
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (forBlob.getTeamNum() == this.getTeamNum() && forBlob.isOverlapping(this) && canSeeButtons(this, forBlob));
}

void onChangeTeam( CBlob@ this, const int oldTeam )
{
	if (getNet().isServer())
	{
		// convert all buildings and doors

		CBlob@[] blobsInRadius;
		if (this.getMap().getBlobsInRadius(this.getPosition(), BASE_RADIUS / 3.0f, @blobsInRadius))
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @b = blobsInRadius[i];
				if (b.getTeamNum() != this.getTeamNum() && (b.hasTag("door") ||
				                                       b.hasTag("building") ||
				                                       b.getName() == "spikes" ||
				                                       b.getName() == "trap_block" ||
													   b.getName() == "bridge"))
				{
					b.server_setTeamNum(this.getTeamNum());
				}
			}
		}
	}
}
