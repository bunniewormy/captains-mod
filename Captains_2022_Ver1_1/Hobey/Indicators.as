#include "pathway.as";

string indicator_pos_property_name  = " indicator_pos";
string indicator_time_property_name = " indicator_time";
string indicator_kind_property_name = " indicator_kind";

string add_indicator_cmd_id         = "add_indicator";

// TODO(hobey): duplication of folder name string constant
string path_string = getCaptainsPath();
string commandsoundslocation = path_string + "CommandSounds/";

void onInit(CRules@ rules) {
    rules.addCommandID(add_indicator_cmd_id);
}

void add_indicator(CRules@ rules, CControls@ controls, CPlayer@ player, s32 kind)
{
    {
        CPlayer@ localplayer = getLocalPlayer();
        bool player_got_muted_indicators   = rules.get_bool(player.getUsername() + "is_hidden");
        bool localplayer_is_blind          = rules.get_bool(localplayer.getUsername() + "is_blind");
        if (player_got_muted_indicators) return;
        if (localplayer_is_blind)        return;
    }
    
    Vec2f pos = controls.getMouseWorldPos();
    
    CBitStream params;
    params.write_netid(player.getNetworkID());
    params.write_Vec2f(pos);
    params.write_u32(getGameTime());
    params.write_s32(kind);
    
    rules.SendCommand(rules.getCommandID(add_indicator_cmd_id), params);
}

void onTick(CRules@ this)
{
    CPlayer@ p = getLocalPlayer();
    if (p is null || !p.isMyPlayer()) { return; }
    
    CControls@ controls = getControls();
    
    // if (controls.isKeyPressed(KEY_LCONTROL) || controls.isKeyPressed(KEY_RCONTROL)) {
    if (((controls.ActionKeyPressed(AK_PARTY) || this.get_bool("indicators_without_mark_button" + p.getUsername())) && (controls.ActionKeyPressed(AK_MENU)))) {
        if (controls.isKeyJustPressed(KEY_KEY_1)) { add_indicator(this, controls, p, 21); }
        if (controls.isKeyJustPressed(KEY_KEY_2)) { add_indicator(this, controls, p, 22); }
        if (controls.isKeyJustPressed(KEY_KEY_3)) { add_indicator(this, controls, p, 23); }
        if (controls.isKeyJustPressed(KEY_KEY_4)) { add_indicator(this, controls, p, 24); }
        if (controls.isKeyJustPressed(KEY_KEY_5)) { add_indicator(this, controls, p, 25); }
        if (controls.isKeyJustPressed(KEY_KEY_6)) { add_indicator(this, controls, p, 26); }
        if (controls.isKeyJustPressed(KEY_KEY_7)) { add_indicator(this, controls, p, 27); }
        if (controls.isKeyJustPressed(KEY_KEY_8)) { add_indicator(this, controls, p, 28); }
        if (controls.isKeyJustPressed(KEY_KEY_9)) { add_indicator(this, controls, p, 29); }
        if (controls.isKeyJustPressed(KEY_KEY_0)) { add_indicator(this, controls, p, 20); }
        
        if (controls.isKeyJustPressed(KEY_NUMPAD1)) { add_indicator(this, controls, p, 51); }
        if (controls.isKeyJustPressed(KEY_NUMPAD2)) { add_indicator(this, controls, p, 52); }
        if (controls.isKeyJustPressed(KEY_NUMPAD3)) { add_indicator(this, controls, p, 53); }
        if (controls.isKeyJustPressed(KEY_NUMPAD4)) { add_indicator(this, controls, p, 54); }
        if (controls.isKeyJustPressed(KEY_NUMPAD5)) { add_indicator(this, controls, p, 55); }
        if (controls.isKeyJustPressed(KEY_NUMPAD6)) { add_indicator(this, controls, p, 56); }
        if (controls.isKeyJustPressed(KEY_NUMPAD7)) { add_indicator(this, controls, p, 57); }
        if (controls.isKeyJustPressed(KEY_NUMPAD8)) { add_indicator(this, controls, p, 58); }
        if (controls.isKeyJustPressed(KEY_NUMPAD9)) { add_indicator(this, controls, p, 59); }
        if (controls.isKeyJustPressed(KEY_NUMPAD0)) { add_indicator(this, controls, p, 50); }
    } else if (controls.ActionKeyPressed(AK_PARTY) || this.get_bool("indicators_without_mark_button" + p.getUsername())) {
        if (controls.isKeyJustPressed(KEY_KEY_1)) { add_indicator(this, controls, p, 1); }
        if (controls.isKeyJustPressed(KEY_KEY_2)) { add_indicator(this, controls, p, 2); }
        if (controls.isKeyJustPressed(KEY_KEY_3)) { add_indicator(this, controls, p, 3); }
        if (controls.isKeyJustPressed(KEY_KEY_4)) { add_indicator(this, controls, p, 4); }
        if (controls.isKeyJustPressed(KEY_KEY_5)) { add_indicator(this, controls, p, 5); }
        if (controls.isKeyJustPressed(KEY_KEY_6)) { add_indicator(this, controls, p, 6); }
        if (controls.isKeyJustPressed(KEY_KEY_7)) { add_indicator(this, controls, p, 7); }
        if (controls.isKeyJustPressed(KEY_KEY_8)) { add_indicator(this, controls, p, 8); }
        if (controls.isKeyJustPressed(KEY_KEY_9)) { add_indicator(this, controls, p, 9); }
        if (controls.isKeyJustPressed(KEY_KEY_0)) { add_indicator(this, controls, p, 0); }
        
        if (controls.isKeyJustPressed(KEY_NUMPAD1)) { add_indicator(this, controls, p, 31); }
        if (controls.isKeyJustPressed(KEY_NUMPAD2)) { add_indicator(this, controls, p, 32); }
        if (controls.isKeyJustPressed(KEY_NUMPAD3)) { add_indicator(this, controls, p, 33); }
        if (controls.isKeyJustPressed(KEY_NUMPAD4)) { add_indicator(this, controls, p, 34); }
        if (controls.isKeyJustPressed(KEY_NUMPAD5)) { add_indicator(this, controls, p, 35); }
        if (controls.isKeyJustPressed(KEY_NUMPAD6)) { add_indicator(this, controls, p, 36); }
        if (controls.isKeyJustPressed(KEY_NUMPAD7)) { add_indicator(this, controls, p, 37); }
        if (controls.isKeyJustPressed(KEY_NUMPAD8)) { add_indicator(this, controls, p, 38); }
        if (controls.isKeyJustPressed(KEY_NUMPAD9)) { add_indicator(this, controls, p, 39); }
        if (controls.isKeyJustPressed(KEY_NUMPAD0)) { add_indicator(this, controls, p, 30); }
    } else if (controls.ActionKeyPressed(AK_MENU)) { // NOTE(hobey): AK_MENU is the "misc" key, backspace by default
        if (controls.isKeyJustPressed(KEY_KEY_1)) { add_indicator(this, controls, p, 11); }
        if (controls.isKeyJustPressed(KEY_KEY_2)) { add_indicator(this, controls, p, 12); }
        if (controls.isKeyJustPressed(KEY_KEY_3)) { add_indicator(this, controls, p, 13); }
        if (controls.isKeyJustPressed(KEY_KEY_4)) { add_indicator(this, controls, p, 14); }
        if (controls.isKeyJustPressed(KEY_KEY_5)) { add_indicator(this, controls, p, 15); }
        if (controls.isKeyJustPressed(KEY_KEY_6)) { add_indicator(this, controls, p, 16); }
        if (controls.isKeyJustPressed(KEY_KEY_7)) { add_indicator(this, controls, p, 17); }
        if (controls.isKeyJustPressed(KEY_KEY_8)) { add_indicator(this, controls, p, 18); }
        if (controls.isKeyJustPressed(KEY_KEY_9)) { add_indicator(this, controls, p, 19); }
        if (controls.isKeyJustPressed(KEY_KEY_0)) { add_indicator(this, controls, p, 10); }
        
        if (controls.isKeyJustPressed(KEY_NUMPAD1)) { add_indicator(this, controls, p, 41); }
        if (controls.isKeyJustPressed(KEY_NUMPAD2)) { add_indicator(this, controls, p, 42); }
        if (controls.isKeyJustPressed(KEY_NUMPAD3)) { add_indicator(this, controls, p, 43); }
        if (controls.isKeyJustPressed(KEY_NUMPAD4)) { add_indicator(this, controls, p, 44); }
        if (controls.isKeyJustPressed(KEY_NUMPAD5)) { add_indicator(this, controls, p, 45); }
        if (controls.isKeyJustPressed(KEY_NUMPAD6)) { add_indicator(this, controls, p, 46); }
        if (controls.isKeyJustPressed(KEY_NUMPAD7)) { add_indicator(this, controls, p, 47); }
        if (controls.isKeyJustPressed(KEY_NUMPAD8)) { add_indicator(this, controls, p, 48); }
        if (controls.isKeyJustPressed(KEY_NUMPAD9)) { add_indicator(this, controls, p, 49); }
        if (controls.isKeyJustPressed(KEY_NUMPAD0)) { add_indicator(this, controls, p, 40); }
    }
}

// NOTE(hobey): only show indicators to teammates and spectators
bool should_show_indicator (CRules@ rules, CPlayer@ player_who_is_indicating) {
    // NOTE(hobey):
    // my_player.getTeamNum() is the team that you are in in the scoreboard;
    // if you do "!team 1" or whatever that will not change whose indicators you can see and who can see yours; changing teams via menu will
    
    CPlayer@ my_player = getLocalPlayer();
    if (my_player !is null && my_player.isMyPlayer()) {
        int my_team_num = my_player.getTeamNum();
        if (((my_team_num == rules.getSpectatorTeamNum()) || (my_team_num == player_who_is_indicating.getTeamNum()))) return true;
    }
    return false;
}

#include "Logging.as"

// TODO(hobey): copy-pasted from ChatCommands.as in CaptainsCORONA69
CPlayer@ GetPlayerByIdent(string ident) {
    // Takes an identifier, which is a prefix of the player's character name
    // or username. If there is 1 matching player then they are returned.
    // If 0 or 2+ then a warning is logged.
    ident = ident.toLower();
    log("GetPlayerByIdent", "ident = " + ident);
    CPlayer@[] matches; // players matching ident
    
    for (int i=0; i < getPlayerCount(); i++) {
        CPlayer@ p = getPlayer(i);
        if (p is null) continue;
        
        string username = p.getUsername().toLower();
        string charname = p.getCharacterName().toLower();
        
        if (username == ident || charname == ident) {
            log("GetPlayerByIdent", "exact match found: " + p.getUsername());
            return p;
        }
        else if (username.find(ident) >= 0 || charname.find(ident) >= 0) {
            matches.push_back(p);
        }
    }
    
    if (matches.length == 1) {
        log("GetPlayerByIdent", "1 match found: " + matches[0].getUsername());
        return matches[0];
    }
    else if (matches.length == 0) {
        logBroadcast("GetPlayerByIdent", "Couldn't find anyone called " + ident);
    }
    else {
        logBroadcast("GetPlayerByIdent", "Multiple people are called " + ident + ", be more specific.");
    }
    
    return null;
}

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
    // RulesCore@ core;
    // this.get("core", @core);
    
    if (player is null)
        return true;
    
    if (text_in == "!ind")
    {
        this.set_bool("indicators_without_mark_button" + player.getUsername(), !this.get_bool("indicators_without_mark_button" + player.getUsername()));
        this.Sync("indicators_without_mark_button" + player.getUsername(), true);
    }

    string[]@ tokens = text_in.split(" ");
    u8 tlen = tokens.length;
    
    if (tokens[0] == "!hide" && player.isMod() && tlen >=2)
    {
        string targetIdent = tokens[1];
        CPlayer@ target = GetPlayerByIdent(targetIdent);
        if (target != null)
        {
            this.set_bool(target.getUsername() + "is_hidden", true);
            this.Sync(target.getUsername() + "is_hidden", true);
        }
    }
    
    else if (tokens[0] == "!unhide" && player.isMod() && tlen >=2)
    {
        string targetIdent = tokens[1];
        CPlayer@ target = GetPlayerByIdent(targetIdent);
        if (target != null)
        {
            this.set_bool(target.getUsername() + "is_hidden", false);
            this.Sync(target.getUsername() + "is_hidden", true);
        }
    }
    if (text_in == "!blind")
    {
        this.set_bool(player.getUsername() + "is_blind", true);
        this.Sync(player.getUsername() + "is_blind", true);
    }
    
    else if (text_in == "!unblind")
    {
        this.set_bool(player.getUsername() + "is_blind", false);
        this.Sync(player.getUsername() + "is_blind", true);
    }
    
    return true;
}

void onCommand(CRules@ rules, u8 cmd, CBitStream @params)
{
    if (cmd == rules.getCommandID(add_indicator_cmd_id)) {
        CPlayer@ player = getPlayerByNetworkId(params.read_netid());
        
        string name = player.getUsername();
        
        CPlayer@ localplayer = getLocalPlayer();
        bool player_got_muted_indicators   = rules.get_bool(player.getUsername() + "is_hidden");
        bool localplayer_is_blind          = rules.get_bool(localplayer.getUsername() + "is_blind");
        if (player_got_muted_indicators) return;
        if (localplayer_is_blind)        return;
        
        Vec2f pos  = params.read_Vec2f();
        u32   time = params.read_u32();
        s32   kind = params.read_s32();
        
        // NOTE(hobey): for testing numpad
        // if (kind >= 0 && kind <= 29) {
        // kind += 30;
        // }
        
        rules.set_Vec2f(name + indicator_pos_property_name, pos);
        rules.set_u32  (name + indicator_time_property_name, time);
        rules.set_s32  (name + indicator_kind_property_name, kind);
        
        if (should_show_indicator(rules, player)) {
            
            // Sound::Play("Sounds/material_drop.ogg");
            
            //////////////////////
            // TODO(hobey): i just pasted all this from CaptainsCORONA69 SoundCommands.as
            // it uses the is_muted, is_deaf, lastsoundplayedtime, soundcooldown that is set from there (and sets lastsoundplayedtime, soundcooldown itself)
            CPlayer@ localplayer = getLocalPlayer();
            bool player_is_muted = rules.get_bool(player.getUsername() + "is_muted");
            bool localplayer_is_deaf = rules.get_bool(localplayer.getUsername() + "is_deaf");
            u32 time_since_last_sound_use = getGameTime() - rules.get_u32(player.getUsername() + "lastsoundplayedtime");
            u32 soundcooldown = rules.get_u32(player.getUsername() + "soundcooldown");
            
            if (player_is_muted == false) {
                if ((time_since_last_sound_use >= soundcooldown)/* || player.isMod()*/) {
                    if (localplayer_is_deaf == false) {
                        rules.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
                        int new_cooldown = 17;
                        
                        if        (kind == 1) { Sound::Play("Sounds/spawn.ogg", pos, .7f); new_cooldown = 10;
                        } else if (kind == 2) { Sound::Play("Sounds/bridge_close.ogg", pos, 8.f);
                        } else if (kind == 3) { Sound::Play("Sounds/depleted.ogg", pos, 0.6f);
                        } else if (kind == 4) { Sound::Play("Sounds/depleting.ogg", pos, 1.f); new_cooldown = 10;
                        } else if (kind == 5) { Sound::Play("Sounds/ReportSound.ogg", pos, .8f); new_cooldown = 11;
                        } else if (kind == 6)  { Sound::Play("Sounds/lightup.ogg", pos, 10.f); new_cooldown = 9;
                        } else if (kind == 7) { Sound::Play("Sounds/bridge_close.ogg", pos, 8.f);
                        } else if (kind == 8) {
                            int random = XORRandom(9) + 1;
                            Sound::Play(commandsoundslocation + "Tuturu" + random + ".ogg", pos); new_cooldown = 45;
                            
                            //////////////////// /
                        } else if (kind == 9) { Sound::Play("Sounds/Gurgle2.ogg", pos, 7.1f); new_cooldown = 12;
                        } else if (kind == 0) { Sound::Play("Sounds/AchievementUnlocked.ogg", pos, .4f); new_cooldown = 48;
                            
                            // }  else if (kind == 4) { Sound::Play("Sounds/hit_wood.ogg", pos, 1.2f);
                            // } else if (kind == 5) { Sound::Play("Sounds/collect.ogg", pos, 1.7f);
                            // } else if (kind == 6) { Sound::Play("Sounds/bone_fall1.ogg", pos, 1.7f);
                            // } else if (kind == 7) { Sound::Play("Sounds/material_drop.ogg", pos);
                            // } else if (kind == 8) { Sound::Play("Sounds/ReportSound.ogg", pos, 1.f);
                            
                            
                            
                        } else if (kind == 11) { Sound::Play("Sounds/throw.ogg", pos, 204.f); new_cooldown = 11;
                        } else if (kind == 12) { Sound::Play("Sounds/depleted.ogg", pos, .6f);
                        } else if (kind == 13) { Sound::Play("Sounds/ReportSound.ogg", pos, .8f); new_cooldown = 11;
                        } else if (kind == 14) { Sound::Play("Sounds/ReportSound.ogg", pos, .8f); new_cooldown = 11;
                        } else if (kind == 15) { Sound::Play("Sounds/lightup.ogg", pos, 8.f); new_cooldown = 9;
                        } else if (kind == 16) { Sound::Play("Sounds/bridge_open.ogg", pos, 3.f);
                            
                        } else if (kind == 17) { Sound::Play("Sounds/party_join.ogg", pos, .55f); new_cooldown = 35;
                        } else if (kind == 18) { Sound::Play("Sounds/party_join.ogg", pos, .55f); new_cooldown = 35;
                        } else if (kind == 19) { Sound::Play("Sounds/party_join.ogg", pos, .55f); new_cooldown = 35;
                        } else if (kind == 10) { Sound::Play("Sounds/party_join.ogg", pos, .55f); new_cooldown = 35;
                            
                        } else if (kind == 21) { Sound::Play("Sounds/coinpick.ogg", pos, .8f); new_cooldown = 15;
                            
                        } else {                 Sound::Play("Sounds/rock_hit3.ogg", pos, 2.f); new_cooldown = 10; // NOTE(hobey): numpad just does this small sound for now
                            //                   Sound::Play("Sounds/ReportSound.ogg", pos, .67f);
                        }
                        
                        rules.set_u32(player.getUsername() + "soundcooldown", new_cooldown);
                    }
                }
            }
        }
    }
}



// NOTE(hobey): clear the indicators on restart, otherwise they reappear on nextmap in some cases
void onRestart(CRules@ rules)
{
    for (int player_index = 0;
         player_index < getPlayerCount();
         player_index++) {
        CPlayer@ player = getPlayer(player_index);
        string name = player.getUsername();
        if (rules.exists (name + indicator_kind_property_name)) {
            rules.set_s32(name + indicator_kind_property_name, -1);
            // rules.Sync   (name + indicator_kind_property_name, true);
        }
    }
}

// NOTE(hobey): not sure if clearing the indicator for people who have left and rejoin is ever necessary; but just to be sure
void onNewPlayerJoin (CRules@ rules, CPlayer@ player)
{
    string name = player.getUsername();
    if (rules.exists (name + indicator_kind_property_name)) {
        rules.set_s32(name + indicator_kind_property_name, -1);
    }
}





string get_font(string file_name, s32 size)
{
    string result = file_name+"_"+size;
    if (!GUI::isFontLoaded(result)) {
        string full_file_name = CFileMatcher(file_name+".ttf").getFirst();
        // TODO(hobey): apparently you cannot load multiple different sizes of a font from the same font file in this api?
        GUI::LoadFont(result, full_file_name, size, true);
    }
    return result;
}

void onRender(CRules@ rules)
{
    for (int player_index = 0;
         player_index < getPlayerCount();
         player_index++) {
        
        CPlayer@ player = getPlayer(player_index);
        
        
        string name = player.getUsername();
        
        if (!rules.exists(name + indicator_pos_property_name)) continue;
        if (!rules.exists(name + indicator_time_property_name)) continue;
        if (!rules.exists(name + indicator_kind_property_name)) continue;
        
        
        // tent swap class without pressing 'e'
        // moving more than 2 tunnels over doesn't clearmenus
        
        if (!should_show_indicator(rules, player)) continue;
        
        s32 indicator_time = s32(rules.get_u32(name + indicator_time_property_name));
        s32 time_elapsed = getGameTime() - indicator_time;
        int indicator_duration = 45;
        if (time_elapsed < 0) continue; // TODO(hobey): print error?
        if (time_elapsed > indicator_duration) continue; // NOTE(hobey): stop drawing the indicator after some time
        
        Vec2f indicator_world_pos = rules.get_Vec2f(name + indicator_pos_property_name);
        Vec2f indicator_screen_pos = getDriver().getScreenPosFromWorldPos(indicator_world_pos);
        
        s32 indicator_kind = rules.get_s32(name + indicator_kind_property_name);
        if (indicator_kind < 0) continue; // NOTE(hobey): can happen, because we set kind to -1 in onRestart
        if (indicator_kind > 59) continue; // TODO(hobey): print error?
        
        float alpha = float(indicator_duration - time_elapsed) / float(indicator_duration);
        SColor color_0 = SColor(   0,   0,   0,   0);
        SColor color_1 = SColor( 255,  255, 255, 255);
        
        string player_display_name = player.getCharacterName();
        string phrase = "uninitialized phrase";
        
        if (indicator_kind == 1) { phrase = "Don't go here!";  color_1 = SColor( 255, 240,  30,  30); }
        if (indicator_kind == 2) { phrase = "Go here!";        color_1 = SColor( 255,  30, 230, 100); }
        if (indicator_kind == 3) { phrase = "Danger!";         color_1 = SColor( 255, 240,  20,  50); }
        if (indicator_kind == 4) { phrase = "Catch!";          color_1 = SColor( 255, 240, 190,  30); }
        if (indicator_kind == 5) { phrase = "Attack here!";    color_1 = SColor( 255, 250, 130,  40); }
        if (indicator_kind == 6) { phrase = "Pickup!";         color_1 = SColor( 255,  50, 190, 230); }
        if (indicator_kind == 7) { phrase = "Stay!";           color_1 = SColor( 255,  20, 240, 120); }
        if (indicator_kind == 8) { phrase = "Tuturu!";         color_1 = SColor( 255,  20, 210, 190); }
        if (indicator_kind == 9) { phrase = "Drop mats!";      color_1 = SColor( 255, 190, 210,  50); }
        if (indicator_kind == 0) { phrase = "HOMEK GOD";       color_1 = SColor( 255, 250, 190,  30); }
        
        if (indicator_kind == 11) { phrase = "Throw here!";    color_1 = SColor( 255, 210, 230,  50); }
        if (indicator_kind == 12) { phrase = "Rats here!";     color_1 = SColor( 255, 230,  30,  50); }
        if (indicator_kind == 13) { phrase = "Collapse here!"; color_1 = SColor( 255, 230, 100,  70); }
        if (indicator_kind == 14) { phrase = "Dig here!";      color_1 = SColor( 255, 210, 160,  20); }
        if (indicator_kind == 15) { phrase = "Use!";           color_1 = SColor( 255,  20, 210, 190); }
        if (indicator_kind == 16) { phrase = "Shield!";        color_1 = SColor( 255,  80,  90, 230); }
        if (indicator_kind == 17) { phrase = "Foodshop!";      color_1 = SColor( 255,  20, 240, 120); }
        if (indicator_kind == 18) { phrase = "Knightshop!";    color_1 = SColor( 255, 250, 130,  40); }
        if (indicator_kind == 19) { phrase = "Archershop!";    color_1 = SColor( 255, 190, 210,  50); }
        if (indicator_kind == 10) { phrase = "Buildershop!";   color_1 = SColor( 255, 230, 190,  50); }
        
        // NOTE(hobey): don't know what extra things should be on numpad; I just threw some random things in here (probably should be custom)
        if (indicator_kind == 21) { phrase = "Nice!";           color_1 = SColor( 255, 210, 230,  50); }
        if (indicator_kind == 22) { phrase = "Stomp!";          color_1 = SColor( 255, 230,  30,  50); }
        if (indicator_kind == 23) { phrase = "Dodge!";          color_1 = SColor( 255, 230, 100,  70); }
        if (indicator_kind == 24) { phrase = "Run!";            color_1 = SColor( 255, 210, 160,  20); }
        if (indicator_kind == 25) { phrase = "Hide!";           color_1 = SColor( 255,  20, 210, 190); }
        if (indicator_kind == 27) { phrase = "Heal!";           color_1 = SColor( 255,  20, 240, 120); }
        if (indicator_kind == 26) { phrase = "Help!";           color_1 = SColor( 255,  80,  90, 230); }
        if (indicator_kind == 28) { phrase = "Stop camping!";   color_1 = SColor( 255, 250, 130,  40); }
        if (indicator_kind == 29) { phrase = "Cap!";            color_1 = SColor( 255, 190, 210,  50); }
        if (indicator_kind == 20) { phrase = "Hello there!";    color_1 = SColor( 255, 230, 190,  50); }
        
        if (indicator_kind == 31) { phrase = "Food!";          color_1 = SColor( 255, 210, 230,  50); }
        if (indicator_kind == 32) { phrase = "Flag!";          color_1 = SColor( 255, 230,  30,  50); }
        if (indicator_kind == 33) { phrase = "Water!";         color_1 = SColor( 255, 230, 100,  70); }
        if (indicator_kind == 34) { phrase = "Burn!";          color_1 = SColor( 255, 210, 160,  20); }
        if (indicator_kind == 35) { phrase = "Bomb!";          color_1 = SColor( 255,  20, 210, 190); }
        if (indicator_kind == 37) { phrase = "Chicken!";       color_1 = SColor( 255,  20, 240, 120); }
        if (indicator_kind == 36) { phrase = "Fishy!";         color_1 = SColor( 255,  80,  90, 230); }
        if (indicator_kind == 38) { phrase = "Shark!";         color_1 = SColor( 255, 250, 130,  40); }
        if (indicator_kind == 39) { phrase = "Bison!";         color_1 = SColor( 255, 190, 210,  50); }
        if (indicator_kind == 30) { phrase = "Crate!";         color_1 = SColor( 255, 230, 190,  50); }
        
        if (indicator_kind == 41) { phrase = "Ladder!";        color_1 = SColor( 255, 210, 230,  50); }
        if (indicator_kind == 42) { phrase = "Wall!";          color_1 = SColor( 255, 230,  30,  50); }
        if (indicator_kind == 43) { phrase = "Doors!";         color_1 = SColor( 255, 230, 100,  70); }
        if (indicator_kind == 44) { phrase = "Tunnel!";        color_1 = SColor( 255, 210, 160,  20); }
        if (indicator_kind == 45) { phrase = "Bridge!";        color_1 = SColor( 255,  20, 210, 190); }
        if (indicator_kind == 47) { phrase = "Close!";         color_1 = SColor( 255,  20, 240, 120); }
        if (indicator_kind == 46) { phrase = "Trap!";          color_1 = SColor( 255,  80,  90, 230); }
        if (indicator_kind == 48) { phrase = "Ballista!";      color_1 = SColor( 255, 250, 130,  40); }
        if (indicator_kind == 49) { phrase = "Catapult!";      color_1 = SColor( 255, 190, 210,  50); }
        if (indicator_kind == 40) { phrase = "Fall!";          color_1 = SColor( 255, 230, 190,  50); }
        
        if (indicator_kind == 51) { phrase = "Coin farm!";        color_1 = SColor( 255, 210, 230,  50); }
        if (indicator_kind == 52) { phrase = "Backwalls!";        color_1 = SColor( 255, 230,  30,  50); }
        if (indicator_kind == 53) { phrase = "Blocks!";           color_1 = SColor( 255, 230, 100,  70); }
        if (indicator_kind == 54) { phrase = "Switch to builder!";color_1 = SColor( 255, 210, 160,  20); }
        if (indicator_kind == 55) { phrase = "Switch to knight!"; color_1 = SColor( 255,  20, 210, 190); }
        if (indicator_kind == 56) { phrase = "Switch to archer!"; color_1 = SColor( 255,  20, 240, 120); }
        if (indicator_kind == 57) { phrase = "Camp!";             color_1 = SColor( 255,  80,  90, 230); }
        if (indicator_kind == 58) { phrase = "Slash!";            color_1 = SColor( 255, 250, 130,  40); }
        if (indicator_kind == 59) { phrase = "Jab!";              color_1 = SColor( 255, 190, 210,  50); }
        if (indicator_kind == 50) { phrase = "Crouch!";           color_1 = SColor( 255, 230, 190,  50); }
        
        // TODO(hobey): DrawText only draws the shadow for some colors? the shadow suddenly disappearing looks ugly when we are fading out
        
        
        
        // GUI::DrawCircle(indicator_screen_pos, 15.f * resolution_scale, color);
        
        SColor phrase_color = color_1.getInterpolated(color_0, alpha);
        SColor name_color   = color_1.getInterpolated(color_0, alpha/* * .80f*/);
        
        float screen_size_x = getDriver().getScreenWidth();
        float screen_size_y = getDriver().getScreenHeight();
        float resolution_scale = screen_size_y / 720.f; // NOTE(hobey): scaling relative to 1280x720
        
        // string phrase_font_name              = get_font("AveriaSerif-Bold", s32(10.f * (screen_size_y / 720.f)));
        string phrase_font_name              = get_font("GenShinGothic-P-Medium", s32(24.f * resolution_scale));
        // string player_display_name_font_name = get_font("DejaVuSans", s32(16.f * (screen_size_y / 720.f)));
        string player_display_name_font_name = get_font("SourceHanSansCN-Regular", s32(16.f * resolution_scale));
        
        // Render::addScript(Render::layer_posthud, "CTF_Interface.as", "draw_indicators", 0.0f);
        
        // NOTE(hobey): draw phrase
        GUI::SetFont(phrase_font_name);
        Vec2f text_dimensions_0;
        GUI::GetTextDimensions(phrase, text_dimensions_0);
        
        // NOTE(hobey): draw the indicator at the edge of the screen if it's off-screen
        // NOTE(hobey): the player_display_name can still go off the screen at the moment
        // TODO(hobey): the chat and other gui elements get draw after this; also clamp indicator_screen_pos around the chat etc?
        if (indicator_screen_pos.x < text_dimensions_0.x * .5f) {
            indicator_screen_pos.x = text_dimensions_0.x * .5f;
        }
        if (indicator_screen_pos.y < text_dimensions_0.y * .5f) {
            indicator_screen_pos.y = text_dimensions_0.y * .5f;
        }
        if (indicator_screen_pos.x >= screen_size_x - text_dimensions_0.x * .5f) {
            indicator_screen_pos.x  = screen_size_x - text_dimensions_0.x * .5f;
        }
        if (indicator_screen_pos.y >= screen_size_y - text_dimensions_0.y * .5f) {
            indicator_screen_pos.y  = screen_size_y - text_dimensions_0.y * .5f;
        }
        
        // GUI::SetFont(phrase_font_name);
        GUI::SetFont(phrase_font_name);
        GUI::DrawText(phrase, indicator_screen_pos - text_dimensions_0 * .5f, phrase_color);
        // GUI::DrawShadowedText(phrase, indicator_screen_pos - text_dimensions_0 * .5f, indicator_screen_pos + text_dimensions_0 * .5f, phrase_color, false, false, false);
        
        // NOTE(hobey): draw player_display_name
        GUI::SetFont(player_display_name_font_name);
        Vec2f text_dimensions_1;
        GUI::GetTextDimensions(player_display_name, text_dimensions_1);
        GUI::DrawText(player_display_name, indicator_screen_pos - text_dimensions_1 * .5f + Vec2f(0.f, text_dimensions_0.y), name_color);
    }
}