// Tent logic

#include "StandardRespawnCommand.as"
#include "StandardControlsCommon.as"
#include "GenericButtonCommon.as"

#include "RulesCore.as";
#include "CTF_Structs.as";
#include "CTF_GiveSpawnItems.as";

const u32 materials_wait_mid = 20; //seconds between free mats
const u32 materials_wait_warmup_mid = 40; //seconds between free mats

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50.0f);

	this.addCommandID("drop mats");

	this.CreateRespawnPoint("tent", Vec2f(0.0f, -4.0f));
	InitClasses(this);
	this.Tag("change class drop inventory");

	this.Tag("respawn");

	// minimap
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 1, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);

	// defaultnobuild
	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 8.0f));
}

void onInit( CInventory@ this )
{
	this.server_SetActive(false);	
}

bool isInventoryAccessible( CBlob@ this, CBlob@ forBlob )
{
	if(forBlob.hasTag("player")) return false;

	return true;
}

void onTick(CBlob@ this)
{
	if (enable_quickswap)
	{
		//quick switch class
		CBlob@ blob = getLocalPlayerBlob();
		if (blob !is null && blob.isMyPlayer())
		{
			if (
				canChangeClass(this, blob) && blob.getTeamNum() == this.getTeamNum() && //can change class
				blob.isKeyJustReleased(key_use) && //just released e
				isTap(blob, 4) && //tapped e
				blob.getTickSinceCreated() > 1 //prevents infinite loop of swapping class
			) {
				CycleClass(this, blob);
			}
		}
	}

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

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	// button for runner
	// create menu for class change
	if (canChangeClass(this, caller) && caller.getTeamNum() == this.getTeamNum())
	{
		caller.CreateGenericButton("$change_class$", Vec2f(0, 0), this, buildSpawnMenu, getTranslatedString("Swap Class"));
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

	else
	{
		onRespawnCommand(this, cmd, params);
	}
}

