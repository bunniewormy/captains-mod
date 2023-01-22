#include "ZonesCommon.as";

void onTick(CRules@ rules)
{
    if(getGameTime() == 45)
    {
        CMap@ map = getMap();
        f32 map_width = map.tilemapwidth*map.tilesize;
        // blue team
        f32 x1 = rules.get_f32("barrier_x1");
        rules.set_f32("zone_a_start_blue", 0.0f);
        rules.set_f32("zone_b_start_blue", x1 + 4.0f * map.tilesize);
        rules.set_f32("zone_c_start_blue", (0.45 * map_width) - ((0.45 * map_width) % 8.0f));

        // red team
        f32 x2 = rules.get_f32("barrier_x2");
        rules.set_f32("zone_a_start_red", map_width);
        rules.set_f32("zone_b_start_red", x2 - 4.0f * map.tilesize);
        rules.set_f32("zone_c_start_red", map_width - (0.45 * map_width));
    }
}

void onPlayerDie( CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData )
{
    if (victim !is null)
    {
        if (victim.getBlob() !is null)
        {
            this.set_string("last death zone " + victim.getUsername(), getPlayersZone(victim));
        }
    }
}

void onRender(CRules@ rules)
{
    CPlayer@ my_player = getLocalPlayer();
    if (my_player is null) return;
    if (!rules.exists("zone_a_start_blue")) return;
    if (getGameTime() < 45) return;
    u8 team = my_player.getTeamNum();

    const f32 scalex = getDriver().getResolutionScaleFactor();
    f32 zoom = getCamera().targetDistance * scalex;

    CMap@ map = getMap();
    f32 map_height = map.tilemapheight*map.tilesize;
        
    if (team == 0)
    {
        SColor color_b = SColor(40, 229, 212, 27);
        Vec2f upperleft_b_1 = getDriver().getScreenPosFromWorldPos(Vec2f(rules.get_f32("zone_b_start_blue"), 0));
        Vec2f lowerright_b_1 = getDriver().getScreenPosFromWorldPos(Vec2f(rules.get_f32("zone_b_start_blue") + 4.0f, getDriver().getScreenHeight()));
        Vec2f upperleft_b_2 = getDriver().getScreenPosFromWorldPos(Vec2f(rules.get_f32("zone_c_start_blue") - 4.0f, 0));
        Vec2f lowerright_b_2 = getDriver().getScreenPosFromWorldPos(Vec2f(rules.get_f32("zone_c_start_blue"), getDriver().getScreenHeight()));
        GUI::DrawRectangle(upperleft_b_1, lowerright_b_1, color_b);
        GUI::DrawRectangle(upperleft_b_2, lowerright_b_2, color_b);

        if (rules.getCurrentState() == WARMUP || rules.getCurrentState() == INTERMISSION)
        {
            Vec2f draw_a_pos = Vec2f(0, 0);
            draw_a_pos.x = rules.get_f32("zone_b_start_blue") / 2 - 32;
            draw_a_pos.y = map_height * 0.2f;
            GUI::DrawIcon("ZoneIcons.png", 0, Vec2f(64, 80), getDriver().getScreenPosFromWorldPos(draw_a_pos), zoom, 0);

            Vec2f draw_b_pos = Vec2f(0, 0);
            draw_b_pos.x = rules.get_f32("zone_b_start_blue") + ((rules.get_f32("zone_c_start_blue") - rules.get_f32("zone_b_start_blue")) / 2) - 32    ;
            draw_b_pos.y = map_height * 0.2f;
            GUI::DrawIcon("ZoneIcons.png", 1, Vec2f(64, 80), getDriver().getScreenPosFromWorldPos(draw_b_pos), zoom, 0);

            Vec2f draw_c_pos = Vec2f(0, 0);
            draw_c_pos.x = rules.get_f32("zone_c_start_blue") + 24;
            draw_c_pos.y = map_height * 0.2f;
            GUI::DrawIcon("ZoneIcons.png", 2, Vec2f(64, 80), getDriver().getScreenPosFromWorldPos(draw_c_pos), zoom, 0);
        }

    }
    else if (team == 1)
    {
        SColor color_b = SColor(40, 229, 212, 27);
        Vec2f upperleft_b_1 = getDriver().getScreenPosFromWorldPos(Vec2f(rules.get_f32("zone_c_start_red") + 5.0f, 0));
        Vec2f lowerright_b_1 = getDriver().getScreenPosFromWorldPos(Vec2f(rules.get_f32("zone_c_start_red") + 9.0f, getDriver().getScreenHeight()));
        Vec2f upperleft_b_2 = getDriver().getScreenPosFromWorldPos(Vec2f(rules.get_f32("zone_b_start_red") - 4.0f, 0));
        Vec2f lowerright_b_2 = getDriver().getScreenPosFromWorldPos(Vec2f(rules.get_f32("zone_b_start_red"), getDriver().getScreenHeight()));
        GUI::DrawRectangle(upperleft_b_1, lowerright_b_1, color_b);
        GUI::DrawRectangle(upperleft_b_2, lowerright_b_2, color_b);

        if (rules.getCurrentState() == WARMUP || rules.getCurrentState() == INTERMISSION)
        {
            Vec2f draw_c_pos = Vec2f(0, 0);
            draw_c_pos.x = rules.get_f32("zone_c_start_red") - 24 - 64;
            draw_c_pos.y = map_height * 0.2f;
            GUI::DrawIcon("ZoneIcons.png", 5, Vec2f(64, 80), getDriver().getScreenPosFromWorldPos(draw_c_pos), zoom, 1);

            Vec2f draw_b_pos = Vec2f(0, 0);
            draw_b_pos.x = rules.get_f32("zone_c_start_red") + ((rules.get_f32("zone_b_start_red") - rules.get_f32("zone_c_start_red")) / 2) - 32    ;
            draw_b_pos.y = map_height * 0.2f;
            GUI::DrawIcon("ZoneIcons.png", 4, Vec2f(64, 80), getDriver().getScreenPosFromWorldPos(draw_b_pos), zoom, 1);

            Vec2f draw_a_pos = Vec2f(0, 0);
            draw_a_pos.x = rules.get_f32("zone_b_start_red") + (map.tilemapwidth * map.tilesize - rules.get_f32("zone_b_start_red")) / 2 - 32;
            draw_a_pos.y = map_height * 0.2f;
            GUI::DrawIcon("ZoneIcons.png", 3, Vec2f(64, 80), getDriver().getScreenPosFromWorldPos(draw_a_pos), zoom, 1);
        }
    }
}
