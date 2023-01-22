#include "CTF_FlagCommon.as";

const u32 start_time = getTicksASecond() * 60 * 40; // 40 minutes
const u32 interval = getTicksASecond() * 60 * 5; // 5 minutes
const u8 max_teleports = 4;

u8 our_teleports = 0;

void onInit(CRules@ this)
{
	this.addCommandID("sector removal sync");
}

void onRestart(CRules@ this)
{
	our_teleports = 0;
}

void onTick(CRules@ this)
{
	u32 current_time = (getRules().exists("match_time") ? getRules().get_u32("match_time") : getGameTime());

	if (isServer())
	{
		if (current_time >= start_time && current_time % interval == 0 && our_teleports < max_teleports)
		{
			our_teleports++;

			CMap@ map = getMap();

			CBlob@[] blist;
					
			if (getBlobsByName("flag_base", blist))
			{
				CBlob@[] flag_base_list_blue;
				f32[] blue_positions;
				CBlob@[] flag_base_list_red;
				f32[] red_positions;

				for (uint step=0; step<blist.length; ++step)
				{
					if (blist[step].getTeamNum() == 0) 
					{
						flag_base_list_blue.push_back(blist[step]);
						blue_positions.push_back(blist[step].getPosition().x);
					}
					else 
					{
						flag_base_list_red.push_back(blist[step]);
						red_positions.push_back(blist[step].getPosition().x);
					}
				}

				blue_positions.sortDesc();
				red_positions.sortAsc();

				CBlob@[] flag_base_list_blue_actual;
				CBlob@[] flag_base_list_red_actual;

				for (int i=0; i<blue_positions.length; ++i)
				{
					f32 current_pos = blue_positions[i];

					for (int k=0; k<flag_base_list_blue.length; ++k)
					{
						if (flag_base_list_blue[k].getPosition().x == current_pos)
						{
							flag_base_list_blue_actual.push_back(flag_base_list_blue[k]);
						}
					}
				}

				for (int i=0; i<red_positions.length; ++i)
				{
					f32 current_pos = red_positions[i];

					for (int k=0; k<flag_base_list_red.length; ++k)
					{
						if (flag_base_list_red[k].getPosition().x == current_pos)
						{
							flag_base_list_red_actual.push_back(flag_base_list_red[k]);
						}
					}
				}

				for (uint step=0; step<flag_base_list_blue_actual.length; ++step)
				{
					CBlob@ flag_base = flag_base_list_blue_actual[step];

					Vec2f pos = flag_base.getPosition();
					u8 team = flag_base.getTeamNum();

					CBitStream params;

					params.write_u16(flag_base.getNetworkID());
					params.write_Vec2f(pos);

					this.SendCommand(this.getCommandID("sector removal sync"), params);

					map.RemoveSectorsAtPosition(pos, "no build", flag_base.getNetworkID());

					map.server_SetTile(pos + Vec2f(-8, 12), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(0, 12), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(8, 12), CMap::tile_empty);

					pos += Vec2f(4 * 8, 0);

					CBlob@[] dieblobs;

					map.getBlobsInBox(pos + Vec2f(-8, -32), pos + Vec2f(8, 12), dieblobs);

					for (int l=0; l<dieblobs.length; ++l)
					{
						if (dieblobs[l] is null) continue;
						if (dieblobs[l].hasTag("player")) continue;
						if (dieblobs[l].getName() == "flag_base") continue;
						if (dieblobs[l].getName() == "ctf_flag") continue;

						dieblobs[l].server_Die();
					}

					flag_base.setPosition(pos);
					flag_base.set_Vec2f("stick position", pos);
					map.server_AddSector(pos + Vec2f(-12, -32), pos + Vec2f(12, 16), "no build", "", flag_base.getNetworkID());

					map.server_SetTile(pos + Vec2f(-8, -28), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(0, -28), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(8, -28), CMap::tile_empty);

					map.server_SetTile(pos + Vec2f(-8, -20), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(0, -20), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(8, -20), CMap::tile_empty);

					map.server_SetTile(pos + Vec2f(-8, -12), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(0, -12), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(8, -12), CMap::tile_empty);

					map.server_SetTile(pos + Vec2f(-8, -4), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(0, -4), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(8, -4), CMap::tile_empty);

					map.server_SetTile(pos + Vec2f(-8, 4), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(0, 4), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(8, 4), CMap::tile_empty);

					map.server_SetTile(pos + Vec2f(-8, 12), CMap::tile_bedrock);
					map.server_SetTile(pos + Vec2f(0, 12), CMap::tile_bedrock);
					map.server_SetTile(pos + Vec2f(8, 12), CMap::tile_bedrock);
				}

				for (uint step=0; step<flag_base_list_red_actual.length; ++step)
				{
					CBlob@ flag_base = flag_base_list_red_actual[step];

					Vec2f pos = flag_base.getPosition();
					u8 team = flag_base.getTeamNum();

					CBitStream params;

					params.write_u16(flag_base.getNetworkID());
					params.write_Vec2f(pos);

					this.SendCommand(this.getCommandID("sector removal sync"), params);

					map.RemoveSectorsAtPosition(pos, "no build", flag_base.getNetworkID());

					map.server_SetTile(pos + Vec2f(-8, 12), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(0, 12), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(8, 12), CMap::tile_empty);

					pos -= Vec2f(4 * 8, 0);

					CBlob@[] dieblobs;

					map.getBlobsInBox(pos + Vec2f(-8, -32), pos + Vec2f(8, 12), dieblobs);

					for (int l=0; l<dieblobs.length; ++l)
					{
						if (dieblobs[l] is null) continue;
						if (dieblobs[l].hasTag("player")) continue;
						if (dieblobs[l].getName() == "flag_base") continue;
						if (dieblobs[l].getName() == "ctf_flag") continue;

						dieblobs[l].server_Die();
					}

					flag_base.setPosition(pos);
					flag_base.set_Vec2f("stick position", pos);
					map.server_AddSector(pos + Vec2f(-12, -32), pos + Vec2f(12, 16), "no build", "", flag_base.getNetworkID());

					map.server_SetTile(pos + Vec2f(-8, -28), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(0, -28), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(8, -28), CMap::tile_empty);

					map.server_SetTile(pos + Vec2f(-8, -20), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(0, -20), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(8, -20), CMap::tile_empty);

					map.server_SetTile(pos + Vec2f(-8, -12), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(0, -12), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(8, -12), CMap::tile_empty);

					map.server_SetTile(pos + Vec2f(-8, -4), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(0, -4), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(8, -4), CMap::tile_empty);

					map.server_SetTile(pos + Vec2f(-8, 4), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(0, 4), CMap::tile_empty);
					map.server_SetTile(pos + Vec2f(8, 4), CMap::tile_empty);

					map.server_SetTile(pos + Vec2f(-8, 12), CMap::tile_bedrock);
					map.server_SetTile(pos + Vec2f(0, 12), CMap::tile_bedrock);
					map.server_SetTile(pos + Vec2f(8, 12), CMap::tile_bedrock);
				}
			}
		}
	}
}

void onRender(CRules@ this)
{
	GUI::SetFont("hud");
	u32 current_time = (getRules().exists("match_time") ? getRules().get_u32("match_time") : getGameTime());

	if (
		(start_time - current_time <= 10 * getTicksASecond() && start_time - current_time > 0 * getTicksASecond()) || 
		(start_time + interval * 1 - current_time <= 10 * getTicksASecond() && start_time + interval * 1 - current_time > 0 * getTicksASecond()) || 
		(start_time + interval * 2 - current_time <= 10 * getTicksASecond() && start_time + interval * 2 - current_time > 0 * getTicksASecond()) || 
		(start_time + interval * 3 - current_time <= 10 * getTicksASecond() && start_time + interval * 3 - current_time > 0 * getTicksASecond()))
	{
		string text = "The flags are going to teleport 4 blocks forward soon!";

		float x = getScreenWidth() / 2;
		float y = getScreenHeight() / 3 + 150;

		SColor color = SColor(255, 255, 55, 55);

		GUI::DrawTextCentered(text, Vec2f(x, y), color);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("sector removal sync") && isClient())
	{
		u16 id = params.read_u16();
		Vec2f pos = params.read_Vec2f();

		getMap().RemoveSectorsAtPosition(pos, "no build", id);
	}
}
