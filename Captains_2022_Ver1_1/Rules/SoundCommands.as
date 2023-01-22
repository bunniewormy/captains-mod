
#include "RulesCore.as";
#include "Logging.as"
#include "pathway.as"

string path_string = getCaptainsPath();
string commandsoundslocation = path_string + "CommandSounds/";

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	RulesCore@ core;
	this.get("core", @core);
	
	if (player is null)
		return true;
		
	string[]@ tokens = text_in.split(" ");
	u8 tlen = tokens.length;
		
	if (tokens[0] == "!mute" && player.isMod() && tlen >=2)
		{
		string targetIdent = tokens[1];
        CPlayer@ target = GetPlayerByIdent(targetIdent);
			if (target != null)
			{
				this.set_bool(target.getUsername() + "is_muted", true);
				this.Sync(target.getUsername() + "is_muted", true);
			}
		}
		
	else if (tokens[0] == "!unmute" && player.isMod() && tlen >=2)
		{
		string targetIdent = tokens[1];
        CPlayer@ target = GetPlayerByIdent(targetIdent);
			if (target != null)
			{
				this.set_bool(target.getUsername() + "is_muted", false);
				this.Sync(target.getUsername() + "is_muted", true);
			}
		}
	if (text_in == "!deafen")
	{
		this.set_bool(player.getUsername() + "is_deaf", true);
		this.Sync(player.getUsername() + "is_deaf", true);
	}
		
	else if (text_in == "!undeafen")
	{
		this.set_bool(player.getUsername() + "is_deaf", false);
		this.Sync(player.getUsername() + "is_deaf", true);
	}
	else if (text_in == "!hidesoundcommands" && player.isMod())	
	{
		this.set_bool("hide_sound_commands", !this.get_bool("hide_sound_commands"));

		if (this.get_bool("hide_sound_commands"))
		{
			getNet().server_SendMsg("Sound commands are hidden");
		}
		else 
		{
			getNet().server_SendMsg("Sound commands are no longer being hidden");	
		}
	}
		
	return true;
}



bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	// Play sounds
	
	bool soundplayed = false;
	CPlayer@ localplayer = getLocalPlayer();
	bool player_is_muted = this.get_bool(player.getUsername() + "is_muted");
	bool localplayer_is_deaf = this.get_bool(localplayer.getUsername() + "is_deaf");
	u32 time_since_last_sound_use = getGameTime() - this.get_u32(player.getUsername() + "lastsoundplayedtime");
	u32 soundcooldown = this.get_u32(player.getUsername() + "soundcooldown");
	
	// Sounds that can be heard only by teammates (you dont need to be alive to use those)
	
	/*if (player_is_muted == false && localplayer.getTeamNum() == player.getTeamNum() && time_since_last_sound_use >= soundcooldown)
	{
		if (text_in == "ez 1vfasfafasfafasfafsfa12"  || text_in == "!p2 edfasfsagafasfaz1v1")
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "conniptions.ogg");
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 45);
			}
	}*/
		
	
	// Taunts (player needs to be alive, can be heard by anyone)
	
	CBlob@ blob = player.getBlob();

    if (blob is null) {
        return true;
    }
	
	Vec2f pos = blob.getPosition();
	
	if (player_is_muted == false && time_since_last_sound_use >= soundcooldown)
		{
			if (text_in == "gives me conniptions"  || text_in == "conniptions") 
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "conniptions.ogg", pos);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 45);
			}
			else if (text_in == "TUTURU" || text_in == "Tuturu!" || text_in == "tuturu" || text_in == "Tuturu" || text_in == "TU TU RU" || text_in == "tu tu ru" || text_in == "tutturu")
			{
				if (localplayer_is_deaf == false)
					{
						int random = XORRandom(9) + 1;
						Sound::Play(commandsoundslocation + "Tuturu" + random + ".ogg", pos);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 45);
			}
			else if (text_in == "not pog" || text_in == "NOT POG" || text_in == "not poggers" || text_in == "NOT POGGERS" || text_in == "unpog" || text_in == "notpoggers")
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "notpoggers2.ogg", pos);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 45);
			}
			else if (text_in == "poggers" || text_in == "POGGERS" || text_in == "pog")
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "poggers.ogg", pos);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 45);
			}
			else if (text_in.find("see", 0) != -1 && text_in.find("chump", 0) != -1)
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "tobey_chump.ogg", pos, 1.0f);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 60);
			}
			else if (text_in.find("forgiveness", 0) != -1 && text_in.find("religion", 0) != -1)
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "tobey_forgiveness.ogg", pos, 1.0f);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 90);
			}
			else if (text_in.find("my", 0) != -1 && text_in.find("back", 0) != -1)
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "tobey_back.ogg", pos, 1.0f);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 180);
			}
			else if (text_in.find("dirt", 0) != -1 && text_in.find("eye", 0) != -1)
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "tobey_dirt.ogg", pos, 1.0f);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 45);
			}
			else if (text_in.find("missed", 0) != -1 && text_in.find("problem", 0) != -1)
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "tobey_missed.ogg", pos, 1.0f);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 120);
			}
			else if (text_in.find("thought", 0) != -1 && text_in.find("earlier", 0) != -1)
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "tobey_thought.ogg", pos, 1.0f);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 60);
			}
			else if (text_in.find("pizza", 0) != -1 && text_in.find("time", 0) != -1)
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "tobey_pizza.ogg", pos, 1.0f);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 60);
			}
			else if (text_in.find("aim issue", 0) != -1)
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "aim_issue.ogg", pos, 1.0f);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			}
			else if (text_in.find("sussy baka", 0) != -1)
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "sussy_baka.ogg", pos, 1.0f);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			}
			else if (text_in.find("peanut brain", 0) != -1)
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "peanut_brain.ogg", pos, 1.0f);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			}
			else if (text_in.find("sus", 0) != -1)
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "sus.ogg", pos, 1.0f);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			}
			else if (text_in.find("junko", 0) != -1 && text_in.find("troll", 0) != -1)
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "junkotroll.ogg", pos, 1.0f);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 60);
			}
			else if (text_in.find("1v1 me", 0) != -1)
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "1v1me.ogg", pos, 1.0f);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			}
			else if (text_in.find("ez 1v1", 0) != -1)
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "ez1v1.ogg", pos, 1.0f);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			}
			else if (text_in.find("amogus", 0) != -1)
			{
				if (localplayer_is_deaf == false)
					{
						int random = XORRandom(2) + 1;
						Sound::Play(commandsoundslocation + "Amogus" + random + ".ogg", pos, 1.0f);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			}
			else if (text_in.find("im a god", 0) != -1)
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "imagod.ogg", pos, 1.0f);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			}
			else if (text_in.find("they having mats for tunel", 0) != -1)
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "matsfortunnel.ogg", pos, 1.0f);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			}
			else if (text_in.find("it cannot be stoped", 0) != -1)
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "cannotbestopped.ogg", pos, 1.0f);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			}
			else if (text_in.find("morbin", 0) != -1 && text_in.find("time", 0) != -1)
			{
				if (localplayer_is_deaf == false)
					{
						Sound::Play(commandsoundslocation + "morbin.ogg", pos, 1.0f);
					}
				this.set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
				this.set_u32(player.getUsername() + "soundcooldown", 30);
			}


		}
	
		return !this.get_bool("hide_sound_commands");
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player) 
{
	this.Sync("hide_sound_commands", true);
}
	
	
CPlayer@ GetPlayerByIdent(string ident) 
{
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