// getRules().set_s32("team0_expensive_zone_x0", 20); getRules().set_s32("team0_expensive_zone_x1", 30);

// TODO(hobey): does not posses authority problems (probably either a sideeffect of lag or a cause of lag); has happened with tent 1,2,3 without e menu mod causing disconnects; test with warboat on captains

/* NOTE(hobey): changes

ExpensiveZone.as
ExpensiveZonePlacement.as
BuilderLogic.as
BasePNGLoader.as
remove PlacementCommon.as (no longer used)

fixed zone being active way earlier than 10 minutes; i forgot to multiply the start time by 30
removed "player is null" print
still trying to figure out the "does not posses authority" thing

*/

void onInit (CRules@ rules) {
    rules.addCommandID("zone");
    rules.addCommandID("zonepos");
    
    rules.set_s32("expensive_zone_cost_percentage", 100); // NOTE(hobey): 1.5x
    rules.set_s32("expensive_zone_start_time", 900); // NOTE(hobey): 15 minutes
    rules.set_s32("expensive_zone_should_round_up_cost", 0);
}

void onNewPlayerJoin (CRules@ rules, CPlayer@ player) {
    if (getNet().isServer()) {
        // print("player "+player.getUsername()+"joined; syncing expensive_zone info to them.");
        
        {
            s32 cost = rules.get_s32("expensive_zone_cost_percentage");
            s32 start_time = rules.get_s32("expensive_zone_start_time");
            s32 round_up = rules.get_s32("expensive_zone_should_round_up_cost");
            CBitStream params;
            params.write_s32(cost);
            params.write_s32(start_time);
            params.write_s32(round_up);
            rules.SendCommand(rules.getCommandID("zone"), params);
        }
        
        {
            s32 team0_x0       = rules.get_s32("team0_expensive_zone_x0");
            s32 team0_x1       = rules.get_s32("team0_expensive_zone_x1");
            s32 team1_x0       = rules.get_s32("team1_expensive_zone_x0");
            s32 team1_x1       = rules.get_s32("team1_expensive_zone_x1");
            CBitStream params;
            params.write_s32(team0_x0);
            params.write_s32(team0_x1);
            params.write_s32(team1_x0);
            params.write_s32(team1_x1);
            rules.SendCommand(rules.getCommandID("zonepos"), params);
        }
    }
}

// NOTE(hobey):
//
// !zone [cost_in_percent] [start_time] [should_round_up]
// !zonepos [blue_left] [blue_right] [red_left] [red_right]
bool onServerProcessChat(CRules@ rules, const string& in text_in, string& out text_out, CPlayer@ player) {
    if (player is null) return true;
    
    string[]@ tokens = text_in.split(" ");
    u8 tlen = tokens.length;
    
    if (tokens[0] == "!zone") {
        
        if ((player.getUsername().toLower() == "homekgod") ||
            (player.getUsername().toLower() == "bunnie")) {
        } else {
            getNet().server_SendMsg("Only bunnie is allowed to use "+tokens[0]);
            return true;
        }
        
        s32 cost = rules.get_s32("expensive_zone_cost_percentage");
        s32 start_time = rules.get_s32("expensive_zone_start_time");
        s32 round_up = rules.get_s32("expensive_zone_should_round_up_cost");
        
        if (tlen >= 2) { cost = parseInt(tokens[1]); }
        if (tlen >= 3) { start_time = parseInt(tokens[2]); }
        if (tlen >= 4) { round_up = parseInt(tokens[3]); }
        
        CBitStream params;
        params.write_s32(cost);
        params.write_s32(start_time);
        params.write_s32(round_up);
        rules.SendCommand(rules.getCommandID("zone"), params);
        
        getNet().server_SendMsg("Building in the expensive zone starts costing "+cost+"% "+ ((round_up != 0) ? "(rounded up) " : "") + "after " + start_time + " seconds of match time.");
        if (tlen < 2) {
            getNet().server_SendMsg("usage: !zone [cost_in_percent] [start_time] [should_round_up]");
        }
    }
    else if (tokens[0] == "!autozone") {
        
        // note: this will break when red zone rewrite will be released, as red zone coords will become u16 
        int offset1 = -10, offset2 = 10;

        if (tlen == 2)
        {
            offset1 = parseInt(tokens[1]);
            offset2 = 10;
        }
        else if (tlen >= 3)
        {
            offset1 = parseInt(tokens[1]);
            offset2 = parseInt(tokens[2]);
        }
        if ((player.getUsername().toLower() == "homekgod") ||
            (player.getUsername().toLower() == "bunnie")) {
        } else {
            getNet().server_SendMsg("Only bunnie is allowed to use "+tokens[0]);
            return true;
        }

        s32 team0_x0       = rules.get_f32("barrier_x1") / getMap().tilesize + offset1;// - 10;
        s32 team0_x1       = rules.get_f32("barrier_x1") / getMap().tilesize + offset2;//+ 10;
        s32 team1_x0       = rules.get_f32("barrier_x2") / getMap().tilesize - offset1;//- 10 - 1;
        s32 team1_x1       = rules.get_f32("barrier_x2") / getMap().tilesize - offset2;//+ 10 - 1;

        CBitStream params;
        params.write_s32(team0_x0);
        params.write_s32(team0_x1);
        params.write_s32(team1_x0);
        params.write_s32(team1_x1);
        
        rules.SendCommand(rules.getCommandID("zonepos"), params);
    }
     else if (tokens[0] == "!zonepos") {
        
        if ((player.getUsername().toLower() == "homekgod") ||
            (player.getUsername().toLower() == "bunnie")) {
        } else {
            getNet().server_SendMsg("Only bunnie is allowed to use "+tokens[0]);
            return true;
        }
        
        s32 team0_x0       = rules.get_s32("team0_expensive_zone_x0");
        s32 team0_x1       = rules.get_s32("team0_expensive_zone_x1");
        s32 team1_x0       = rules.get_s32("team1_expensive_zone_x0");
        s32 team1_x1       = rules.get_s32("team1_expensive_zone_x1");
        
        if (tlen >= 2) { team0_x0 = parseInt(tokens[1]); }
        if (tlen >= 3) { team0_x1 = parseInt(tokens[2]); }
        if (tlen >= 4) { team1_x0 = parseInt(tokens[3]); }
        if (tlen >= 5) { team1_x1 = parseInt(tokens[4]); }
        
        CBitStream params;
        params.write_s32(team0_x0);
        params.write_s32(team0_x1);
        params.write_s32(team1_x0);
        params.write_s32(team1_x1);
        rules.SendCommand(rules.getCommandID("zonepos"), params);
        
        getNet().server_SendMsg(""+team0_x0+" "+team0_x1+" "+team1_x0+" "+team1_x1);
        if (tlen < 2) {
            getNet().server_SendMsg("usage: !zonepos [blue_left] [blue_right] [red_left] [red_right]");
        }
    }
    return true;
}

void onCommand(CRules@ rules, u8 cmd, CBitStream @params)
{
    if (cmd == rules.getCommandID("zone")) {
        s32 cost       = params.read_s32();
        s32 start_time = params.read_s32();
        s32 round_up   = params.read_s32();
        rules.set_s32("expensive_zone_cost_percentage", cost);
        rules.set_s32("expensive_zone_start_time", start_time);
        rules.set_s32("expensive_zone_should_round_up_cost", round_up);
    }
    if (cmd == rules.getCommandID("zonepos")) {
        s32 team0_x0       = params.read_s32();
        s32 team0_x1       = params.read_s32();
        s32 team1_x0       = params.read_s32();
        s32 team1_x1       = params.read_s32();
        rules.set_s32("team0_expensive_zone_x0", team0_x0);
        rules.set_s32("team0_expensive_zone_x1", team0_x1);
        rules.set_s32("team1_expensive_zone_x0", team1_x0);
        rules.set_s32("team1_expensive_zone_x1", team1_x1);
    }
}









void onRender(CRules@ rules)
{
    CPlayer@ my_player = getLocalPlayer();
    if (my_player is null) return;
    s32 cost = getRules().get_s32("expensive_zone_cost_percentage");
    if (cost == 100 || cost == 0) return;
    
    if (!rules.exists("team"+my_player.getTeamNum()+"_expensive_zone_x0")) return;
    if (!rules.exists("team"+my_player.getTeamNum()+"_expensive_zone_x1")) return;
    int x0 = rules.get_s32("team"+my_player.getTeamNum()+"_expensive_zone_x0");
    int x1 = rules.get_s32("team"+my_player.getTeamNum()+"_expensive_zone_x1");
    
    for (int i = 0; i < 2; i++) {
        int x = x0;
        if (i == 1) x = x1 + 1;
        
        // (heal_bomb, healkeg, backwallkeg, builderautopickup, expensive_zone)
        
        s32 expensive_zone_start_time = rules.get_s32("expensive_zone_start_time") * 30;
        int match_time = (rules.exists("match_time") ? rules.get_u32("match_time") : 0);
        
        SColor color = SColor(60, 20, 120, 50);
        if (match_time < expensive_zone_start_time) {
            if ((my_player.getBlob() !is null) && (my_player.getBlob().getName() == "builder")) {
                color = SColor(20, 20, 120, 50);
            } else {
                color = SColor(12, 20, 120, 50);
            }
        } else {
            if ((my_player.getBlob() !is null) && (my_player.getBlob().getName() == "builder")) {
                color = SColor(60, 20, 220, 150);
            } else {
                color = SColor(24, 20, 220, 150);
            }
        }
        
        
        
        float half_width = 2.f;
        Vec2f upperleft  = getDriver().getScreenPosFromWorldPos(Vec2f(float(x*8)-half_width, 0));
        Vec2f lowerright = getDriver().getScreenPosFromWorldPos(Vec2f(float(x*8)+half_width, 0));
        upperleft .y = 0;
        lowerright.y = getDriver().getScreenHeight();
        
        GUI::DrawRectangle(upperleft, lowerright, color);
    }
}
