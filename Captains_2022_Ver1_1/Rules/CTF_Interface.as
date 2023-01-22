#include "CTF_Structs.as";
#include "ZonesCommon.as";

u32 wood_count_blue = 0;
u32 wood_count_red = 0;
u32 stone_count_blue = 0;
u32 stone_count_red = 0;
u32 gold_count_blue = 0;
u32 gold_count_red = 0;

void onTick(CRules@ this)
{
	if (getGameTime() % 30 == 0)
	{
		CMap@ map = getMap();

			CBlob@[] wood_list;
			getBlobsByName("mat_wood", @wood_list);
			wood_count_blue = 0;
			wood_count_red = 0;
			for (int i=0; i<wood_list.length; ++i)
			{
				Vec2f pos_to_use = wood_list[i].getPosition();
				if(wood_list[i].isInInventory())
				{
					if(wood_list[i].getInventoryBlob() !is null)
					{
						pos_to_use = wood_list[i].getInventoryBlob().getPosition();
					}
				}

				if (pos_to_use.x < map.tilemapwidth * 8 / 2)
				{
					wood_count_blue += wood_list[i].getQuantity();
				}
				else
				{
					wood_count_red += wood_list[i].getQuantity();
				}
			}

			CBlob@[] stone_list;
			getBlobsByName("mat_stone", @stone_list);
			stone_count_blue = 0;
			stone_count_red = 0;
			for (int i=0; i<stone_list.length; ++i)
			{
				Vec2f pos_to_use = stone_list[i].getPosition();
				if(stone_list[i].isInInventory())
				{
					if(stone_list[i].getInventoryBlob() !is null)
					{
						pos_to_use = stone_list[i].getInventoryBlob().getPosition();
					}
				}

				if (pos_to_use.x < map.tilemapwidth * 8 / 2)
				{
					stone_count_blue += stone_list[i].getQuantity();
				}
				else
				{
					stone_count_red += stone_list[i].getQuantity();
				}
			}

			CBlob@[] gold_list;
			getBlobsByName("mat_gold", @gold_list);
			gold_count_blue = 0;
			gold_count_red = 0;
			for (int i=0; i<gold_list.length; ++i)
			{
				Vec2f pos_to_use = gold_list[i].getPosition();
				if(gold_list[i].isInInventory())
				{
					if(gold_list[i].getInventoryBlob() !is null)
					{
						pos_to_use = gold_list[i].getInventoryBlob().getPosition();
					}
				}

				if (pos_to_use.x < map.tilemapwidth * 8 / 2)
				{
					gold_count_blue += gold_list[i].getQuantity();
				}
				else
				{
					gold_count_red += gold_list[i].getQuantity();
				}
			}
	}

	if (isClient() && getLocalPlayer() !is null)
	{
		if (getGameTime() % 10 == 0)
		{
			this.set_string("zone_for_draw_" + getLocalPlayer().getUsername(), getPlayersZone(getLocalPlayer()));
		}
	}
}

void onInit(CRules@ this)
{
    onRestart(this);
}

void onRestart( CRules@ this )
{
    UIData ui;

    CBlob@[] flags;
    if(getBlobsByName("ctf_flag", flags))
    {
        for(int i = 0; i < flags.size(); i++)
        {
            CBlob@ blob = flags[i];

            ui.flagIds.push_back(blob.getNetworkID());
            ui.flagStates.push_back("f");
            ui.flagTeams.push_back(blob.getTeamNum());
            ui.addTeam(blob.getTeamNum());


        }

    }

    this.set("uidata", @ui);

    CBitStream bt = ui.serialize();

	this.set_CBitStream("ctf_serialised_team_hud", bt);
	this.Sync("ctf_serialised_team_hud", true);

	//set for all clients to ensure safe sync
	this.set_s16("stalemate_breaker", 0);

}

//only for after the fact if you spawn a flag
void onBlobCreated( CRules@ this, CBlob@ blob )
{
    if(!getNet().isServer())
        return;

    if(blob.getName() == "ctf_flag")
    {
        UIData@ ui;
        this.get("uidata", @ui);

        if(ui is null) return;

        ui.flagIds.push_back(blob.getNetworkID());
        ui.flagStates.push_back("f");
        ui.flagTeams.push_back(blob.getTeamNum());
        ui.addTeam(blob.getTeamNum());

        CBitStream bt = ui.serialize();

		this.set_CBitStream("ctf_serialised_team_hud", bt);
		this.Sync("ctf_serialised_team_hud", true);

    }

}

void onBlobDie( CRules@ this, CBlob@ blob )
{
    if(!getNet().isServer())
        return;

    if(blob.getName() == "ctf_flag")
    {
        UIData@ ui;
        this.get("uidata", @ui);

        if(ui is null) return;

        int id = blob.getNetworkID();

        for(int i = 0; i < ui.flagIds.size(); i++)
        {
            if(ui.flagIds[i] == id)
            {
                ui.flagStates[i] = "c";

            }

        }

        CBitStream bt = ui.serialize();

		this.set_CBitStream("ctf_serialised_team_hud", bt);
		this.Sync("ctf_serialised_team_hud", true);

    }

}

void onRender(CRules@ this)
{
	if (g_videorecording)
		return;

	CPlayer@ p = getLocalPlayer();

	if (p is null || !p.isMyPlayer()) { return; }

	CBitStream serialised_team_hud;
	this.get_CBitStream("ctf_serialised_team_hud", serialised_team_hud);

	if (serialised_team_hud.getBytesUsed() > 8)
	{
		serialised_team_hud.Reset();
		u16 check;

		if (serialised_team_hud.saferead_u16(check) && check == 0x5afe)
		{
			const string gui_image_fname = "Rules/CTF/CTFGui.png";

			int something_else = 0;

			u8 flag_amount = 0;

			while (!serialised_team_hud.isBufferEnd())
			{
				CTF_HUD hud(serialised_team_hud);
				Vec2f topLeft = Vec2f(8, 8 + 64 * hud.team_num);

				flag_amount = hud.team_num + 1;

				int step = 0;
				Vec2f startFlags = Vec2f(0, 8);

				string pattern = hud.flag_pattern;
				string flag_char = "";
				int size = int(pattern.size());
				something_else = size;

				GUI::DrawRectangle(topLeft + Vec2f(4, 4), topLeft + Vec2f(size * 32 + 26, 60));

				while (step < size)
				{
					flag_char = pattern.substr(step, 1);

					int frame = 0;
					//c captured
					if (flag_char == "c")
					{
						frame = 2;
					}
					//m missing
					else if (flag_char == "m")
					{
						frame = getGameTime() % 20 > 10 ? 1 : 2;
					}
					//f fine
					else if (flag_char == "f")
					{
						frame = 0;
					}

					GUI::DrawIcon(gui_image_fname, frame , Vec2f(16, 24), topLeft + startFlags + Vec2f(14 + step * 32, 0) , 1.0f, hud.team_num);

					step++;
				}
			}

			Vec2f topLeft = Vec2f(8, 8 + 64 * flag_amount);
			SColor colorcock = SColor(255, 255, 255, 255);
			GUI::DrawPane(topLeft + Vec2f(4, 4), topLeft + Vec2f(64, 64));
			string our_string = this.get_string("zone_for_draw_" + p.getUsername());

			string big_string = "null";

			GUI::SetFont("hud");

			if (our_string == "a")
			{
				big_string = "A";
				GUI::DrawIcon("ZoneIcons.png", 6, Vec2f(64, 80), (topLeft + Vec2f(4, -4)), 0.5, p.getTeamNum());
			}
				if (our_string == "b")
			{
				big_string = "B";
				GUI::DrawIcon("ZoneIcons.png", 7, Vec2f(64, 80), (topLeft + Vec2f(4, -4)), 0.5, p.getTeamNum());
			}
			if (our_string == "c")
			{
				big_string = "C";
				GUI::DrawIcon("ZoneIcons.png", 8, Vec2f(64, 80), (topLeft + Vec2f(4, -4)), 0.5, p.getTeamNum());
			}

			CControls@ c = p.getControls();

			if (c.getMouseScreenPos().x > topLeft.x + 4 && c.getMouseScreenPos().x < topLeft.x + 64 && c.getMouseScreenPos().y > topLeft.y + 4 && c.getMouseScreenPos().y < topLeft.y + 64)
			{
				SColor colorura = SColor(255, 255, 255, 255);
				SColor colorbubu = SColor(255, 255, 221, 156);
				string bubucock = "You are currently in zone " + big_string + "\n\n";
				string zonea = "Zone A - your team’s start territory.\n\nStarts on the border of the map & ends a few blocks into the red buildtime zone. \nOnce the game starts, all blocks built inside zone A cost 150% of original cost.\n90% of coin gain from kills inside it.\n150% of normal coin loss from deaths in it. (15% of all coins)\nBuilders in your team drop 80% materials on ground when killed there; the other 20% is transferred (teleported) directly to the enemy's tent.";
				string zoneb = "Zone B - pre-mid.\n\nStarts where zone A ends and ends a few blocks before mid.\nStone blocks and stone doors cannot be built in it. 100% cost for all other blocks.\n100% of normal coin gain.\n125% of normal coin loss (12.5%)\nBuilders in your team drop 100% of materials on death in there.";
				string zonec = "Zone C - enemy territory.\n\nStarts where zone B ends.\nAll blocks built there cost 80% of original cost (Stone blocks - 8 stone, spikes - 24 stone, shop - 120 wood..)\n120% of normal coin gain.\n100% of normal coin loss (10%).\nBuilders in your team drop 75% of materials on ground when killed there. The other 25% is transferred (teleported) directly back to your team’s tent.\n";
				GUI::DrawPane(topLeft + Vec2f(80, 4), topLeft + Vec2f(1200, 440), SColor(255, 150, 150, 150));
				Vec2f dim = Vec2f_zero;
				GUI::GetTextDimensions(bubucock, dim);
				GUI::DrawText(bubucock, topLeft + Vec2f(84, 8) + Vec2f(640 - dim.x, 6), SColor(255, 255, 255, 255));

				GUI::DrawText(zonea, topLeft + Vec2f(84, 8) + Vec2f(0, dim.y + 4), our_string == "a" ? colorbubu : colorura);
				Vec2f dim2 = Vec2f_zero;
				GUI::GetTextDimensions(zonea, dim2);

				GUI::DrawText(zoneb, topLeft + Vec2f(84, 8) + Vec2f(0, dim.y + dim2.y + 4), our_string == "b" ? colorbubu : colorura);
				Vec2f dim3 = Vec2f_zero;
				GUI::GetTextDimensions(zoneb, dim3);

				GUI::DrawText(zonec, topLeft + Vec2f(84, 8) + Vec2f(0, dim.y + dim2.y + dim3.y + 4), our_string == "c" ? colorbubu : colorura);
			}

			Vec2f continueTopLeft = Vec2f(40 + something_else * 32, 16);

			CMap@ map = getMap();

			CTeam@ blue = getRules().getTeam(0);
			string blue_wood_message = wood_count_blue;
			string blue_stone_message = stone_count_blue;
			string blue_gold_message = gold_count_blue;
			u16 leftside_indent = 4;
			u16 text_indent = 32;
			u16 material_display_width = 80;
			u16 material_display_height = 40;
			Vec2f icon_dimensions = Vec2f(16, 16);
			string icon = "Materials.png";
			SColor wood_color = SColor(255, 164, 103, 39);
			SColor stone_color = SColor(255, 151, 167, 146);
			SColor gold_color = SColor(255, 254, 165, 61);
			GUI::DrawPane(continueTopLeft + Vec2f(0, 4), continueTopLeft + Vec2f(material_display_width*3+leftside_indent, material_display_height), blue.color);
			//wood
			GUI::DrawIcon(
				icon,
				25, //matwood icon
				icon_dimensions,
				continueTopLeft + Vec2f(leftside_indent, 0),
				1.0f,
				0);
			GUI::DrawText(blue_wood_message, continueTopLeft + Vec2f(leftside_indent*1.5+32, material_display_height/3), wood_color);
			//stone
			GUI::DrawIcon(
				icon,
				24, //matstone icon
				icon_dimensions,
				continueTopLeft + Vec2f(leftside_indent+material_display_width, 0),
				1.0f,
				0);
			GUI::DrawText(blue_stone_message, continueTopLeft + Vec2f(leftside_indent*1.5+material_display_width+text_indent, material_display_height/3), stone_color);
			//gold
			GUI::DrawIcon(
				icon,
				26, //matgold icon
				icon_dimensions,
				continueTopLeft + Vec2f(leftside_indent+material_display_width*2, 0),
				1.0f,
				0);
			GUI::DrawText(blue_gold_message, continueTopLeft + Vec2f(leftside_indent*1.5+material_display_width*2+text_indent, material_display_height/3), gold_color);

			continueTopLeft += Vec2f(0, 64);

			CTeam@ red = getRules().getTeam(1);
			string red_wood_message = wood_count_red;
			string red_stone_message = stone_count_red;
			string red_gold_message = gold_count_red;
			GUI::DrawPane(continueTopLeft + Vec2f(0, 4), continueTopLeft + Vec2f(material_display_width*3+leftside_indent, material_display_height), red.color);
			//wood
			GUI::DrawIcon(
				icon,
				25, //matwood icon
				icon_dimensions,
				continueTopLeft + Vec2f(leftside_indent, 0),
				1.0f,
				0);
			GUI::DrawText(red_wood_message, continueTopLeft + Vec2f(leftside_indent*1.5+32, material_display_height/3), wood_color);
			//stone
			GUI::DrawIcon(
				icon,
				24, //matstone icon
				icon_dimensions,
				continueTopLeft + Vec2f(leftside_indent+material_display_width, 0),
				1.0f,
				0);
			GUI::DrawText(red_stone_message, continueTopLeft + Vec2f(leftside_indent*1.5+material_display_width+text_indent, material_display_height/3), stone_color);
			//gold
			GUI::DrawIcon(
				icon,
				26, //matgold icon
				icon_dimensions,
				continueTopLeft + Vec2f(leftside_indent+material_display_width*2, 0),
				1.0f,
				0);
			GUI::DrawText(red_gold_message, continueTopLeft + Vec2f(leftside_indent*1.5+material_display_width*2+text_indent, material_display_height/3), gold_color);
		}

		serialised_team_hud.Reset();
	}

	string propname = "ctf spawn time " + p.getUsername();
	if (p.getBlob() is null && this.exists(propname))
	{
		u8 spawn = this.get_u8(propname);

		if (spawn != 255)
		{
			string spawn_message = getTranslatedString("Respawning in: {SEC}").replace("{SEC}", ((spawn > 250) ? getTranslatedString("approximatively never") : ("" + spawn)));

			GUI::SetFont("hud");
			GUI::DrawText(spawn_message , Vec2f(getScreenWidth() / 2 - 70, getScreenHeight() / 3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f), SColor(255, 255, 255, 55));
		}
	}
}

void onNewPlayerJoin( CRules@ this, CPlayer@ player )
{
	this.SyncToPlayer("ctf_serialised_team_hud", player);
}
