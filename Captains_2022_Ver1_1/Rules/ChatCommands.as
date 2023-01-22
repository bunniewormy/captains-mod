// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out

#include "Logging.as"
#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";
#include "RulesCore.as";

const int TEAM_BLUE = 0;
const int TEAM_RED  = 1;

u16[] blocked;

string[] classlock_users;
string[] classlock_classes;

string[] tobeyquotes = {
	"Pizza time!",
	"You should've thought of that earlier",
	"See ya chump!",
	"I missed the part where that's my problem",
	"You want forgiveness? Get religion",
	"I need that money!",
	"You'll get your rent when you fix this damn door!",
	"I shined my shoes, pressed my pants, did my homework.",
	"Whatever life holds in store for me, I will never forget these words: With great power comes great responsibility. This is my gift, my curse. Who am I? I'm Spider-man.",
	"I'm gonna put some dirt in your eye",
	"Stings, doesn't it?",
	"Shazam!",
	"Sorry I'm late, it's a jungle out there, I had to beat an old lady with a stick to get this",
	"Look at little goblin junior. Gonna cry?",
	"Still got the moves!",
	"I'm really gonna enjoy this",
	"Go web go!",
	"Tally ho!",
	"Now dig on this!",
	"I've been reading poetry lately"
};

bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	if (blocked.find(player.getNetworkID()) != -1) return true;

	RulesCore@ core;
	this.get("core", @core);

	if (player is null)
		return true;

	if(text_in.findFirst("!mapcycle") != -1 && player.isMod())
	{
		string[]@ split = text_in.split(" ");
		if(split.size() > 1)
		{
			if(LoadMapCycle(split[1]))
			{
				print("success");

			}

		}

	}
    else if (text_in == "!allspec" && player.isMod())
    {
    	for (int i=0; i < getPlayerCount(); i++) 
			{
				CPlayer@ p = getPlayer(i);
				if (p is null) continue;
				ChangePlayerTeam(this, p, this.getSpectatorTeamNum());
			}
    }
	
	
	else if (text_in == "!startoffi" && player.isMod())
	{
		LoadNextMap();
		this.Tag("offi match");
	}
	else if (text_in == "!stopoffi" && player.isMod())
	{
		this.Untag("offi match");
	}

	else if (text_in == "!startgame" && player.isMod())
	{
		this.SetCurrentState(GAME);
		return true;
	}

	else if (text_in == "!lockteams" && player.isMod()) 
	{
        getRules().set_bool("teams_locked", !getRules().get_bool("teams_locked"));

        if (getRules().get_bool("teams_locked"))
            getNet().server_SendMsg("Teams are locked.");
        else
            getNet().server_SendMsg("Teams are unlocked.");
    }
    else if (text_in == "!unlockteams" && player.isMod())
    {
		getRules().set_bool("teams_locked", false);    	
		getNet().server_SendMsg("Teams are unlocked.");	
    }
	
	string[]@ tokens = text_in.split(" ");
	u8 tlen = tokens.length;
	
	if (tokens[0] == "!settickets" && player.isMod()) 
	{
		if (tokens.length > 1)
		{
			s16 numTix = parseInt(tokens[1]);
	    	this.set_s16("redTickets", numTix);
			this.set_s16("blueTickets", numTix);
			this.Sync("redTickets", true);
			this.Sync("blueTickets", true);
		}
    }
    else if (tokens[0] == "!setredtickets" && player.isMod()) {
		if (tokens.length > 1)
		{
			s16 numTix = parseInt(tokens[1]);
	    	this.set_s16("redTickets", numTix);
			this.Sync("redTickets", true);
		}
    }
    else if (tokens[0] == "!setbluetickets" && player.isMod()) {
		if (tokens.length > 1)
		{
			s16 numTix = parseInt(tokens[1]);
			this.set_s16("blueTickets", numTix);
			this.Sync("blueTickets", true);
		}
    }
	else if (tokens[0] == "!blockcommands" && player.isMod())
	{
		CPlayer@ p = GetPlayerByIdent(tokens[1]);
		if (p !is null)
		{
			if (blocked.find(p.getNetworkID()) == -1)
			{
				blocked.insertLast(p.getNetworkID());
			}
		}
	}
	else if (tokens[0] == "!lockclass" && player.isMod())
	{
		CPlayer@ p = GetPlayerByIdent(tokens[1]);
		if (p !is null)
		{
			string locked_class = tokens[2];

			if (locked_class == "builder" || locked_class == "archer" || locked_class == "knight")
			{
				this.set_bool(p.getUsername() + "_lock_" + locked_class, !this.get_bool(p.getUsername() + "_lock_" + locked_class));
				this.Sync(p.getUsername() + "_lock_" + locked_class, true);

				if (this.get_bool(p.getUsername() + "_lock_" + locked_class))
				{
					getNet().server_SendMsg("Locked class: " + locked_class + " for player: " + p.getUsername());
					classlock_users.push_back(p.getUsername());
					classlock_classes.push_back(locked_class);
				}
				else
				{
					int index = classlock_users.find(p.getUsername());

					if (index > classlock_users.length || index > classlock_classes.length)
					{
						getNet().server_SendMsg("tell bunnie somethings fucked with class locking arrays");
					}
					else
					{
						classlock_users.removeAt(index);
						classlock_classes.removeAt(index);
						getNet().server_SendMsg("Unlocked class: " + tokens[2] + " for player: " + p.getUsername());
					}
				}
			}
			else
			{
				getNet().server_SendMsg("No class found: " + tokens[2]);
			}
		}
		else
		{
			getNet().server_SendMsg("Lock class failed");
		}
	}
	else if (tokens[0] == "!listlocks" && player.isMod())
	{
		for (int i = 0; i < classlock_users.length; ++i)
		{
			getNet().server_SendMsg(classlock_users[i] + " locked out of playing " + classlock_classes[i]);
		}
	}
	else if (tokens[0] == "!unblockcommands" && player.isMod())
	{
		CPlayer@ p = GetPlayerByIdent(tokens[1]);
		if (p !is null)
		{
			u8 index = blocked.find(p.getNetworkID());
			if (index != -1)
			{
				blocked.removeAt(index);
			}
		}
	}
	else if (tokens[0] == "!players" && tlen>=3 && player.isMod()) 
	{			
		u8 tlen1 = 0;
		if (tlen%2==1) 
		{
			tlen1 = tlen/2;
		} 
		else 
		{
			tlen1 = (tlen-1)/2;
		}
		for (int i=1; i <= tlen1; i++) 
		{
			CBlob@[] all;
			getBlobs( @all );
			string targetIdent = tokens[i];
			logBroadcast("GetPlayerByIdent", "Trying to move " + targetIdent + " to blue");
				CPlayer@ target = GetPlayerByIdent(targetIdent);
			if(target != null)
			{
				ChangePlayerTeam(this, target, TEAM_BLUE);
			}		
		}

		for (int i=i; i < tlen; i++) 
		{
			CBlob@[] all;
			getBlobs( @all );
			string targetIdent = tokens[i];
			logBroadcast("GetPlayerByIdent", "Trying to move " + targetIdent + " to red");
				CPlayer@ target = GetPlayerByIdent(targetIdent);
			if(target != null)
			{
				ChangePlayerTeam(this, target, TEAM_RED);
			}			
		}
		
	}
	
		else if (tokens[0] == "!shuffleall" && player.isMod())
		{
			for (int i=0; i < getPlayerCount(); i++) 
			{
				CPlayer@ p = getPlayer(i);
				if (p is null) continue;
				u8 team = XORRandom(2);
				u8 playersinteam = getPlayerCount()/2;
				if (CountPlayersInTeam(team) > playersinteam)
					if (team == 1) team = 0;
				else team = 1;
				
				ChangePlayerTeam(this, p, team);
			}
		}
		
		else if (tokens[0] == "!shuffleallbut" && player.isMod())
		{
			tokens.removeAt(0);
			for (int i=0; i < tokens.length(); i++)
			{
				if (GetPlayerByIdent(tokens[i]) != null)
					tokens[i] = GetPlayerByIdent(tokens[i]).getUsername();
				else 
				{
					tokens.removeAt(i);
					i -= 1;
				}
			}
			
			u8 team = XORRandom(2);
			u8 playersinteam = (getPlayerCount() - tokens.length())/2;
			
			for (int i=0; i < getPlayerCount(); i++) 
			{
				CPlayer@ p = getPlayer(i);
				if (p is null || tokens.find(p.getUsername()) >= 0) continue;
				if (CountPlayersInTeam(team) > playersinteam)
					if (team == 1) team = 0;
				else team = 1;
				
				ChangePlayerTeam(this, p, team);
			}
		}
	
		else if (tokens[0]=="!blue" && tlen>=2 && player.isMod()) 
		{
			CBlob@[] all;
			getBlobs( @all );
			string targetIdent = tokens[1];
            CPlayer@ target = GetPlayerByIdent(targetIdent);
			if(target != null)
			{
				ChangePlayerTeam(this, target, TEAM_BLUE);
			}
		
		}
		
		else if (tokens[0]=="!red" && tlen>=2 && player.isMod()) 
		{
			CBlob@[] all;
			getBlobs( @all );
			string targetIdent = tokens[1];
            CPlayer@ target = GetPlayerByIdent(targetIdent);
			if(target != null)
			{
				ChangePlayerTeam(this, target, TEAM_RED);
			}
		
		}
		
		else if (tokens[0] == "!spec" && tlen >= 2 && player.isMod())
		{
			CBlob@[] all;
			getBlobs( @all );
			string targetIdent = tokens[1];
            CPlayer@ target = GetPlayerByIdent(targetIdent);
				if(target != null)
				{
					ChangePlayerTeam(this, target, this.getSpectatorTeamNum());
				}           
		}
		/*else if (tokens[0] == "!loadmap" && tlen >= 2 && player.isMod())
		{
			LoadMap(CFileMatcher(tokens[1]).getFirst());
		}*/

	
    CBlob@ blob = player.getBlob();

    if (blob is null) {
        return true;
    }
	
	Vec2f pos = blob.getPosition();
	//commands that don't rely on sv_test

	if (text_in == "!killme")
    {
        blob.server_Hit( blob, blob.getPosition(), Vec2f(0,0), 4.0f, 0);
    }
	else if (text_in == "!bot" && player.isMod()) // TODO: whoaaa check seclevs
    {
        CPlayer@ bot = AddBot( "Henry" );
        return true;
    }
    else if (text_in == "!debug" && player.isMod())
    {
        // print all blobs
        CBlob@[] all;
        getBlobs( @all );

        for (u32 i=0; i < all.length; i++)
        {
            CBlob@ blob = all[i];
            print("["+blob.getName()+" " + blob.getNetworkID() + "] ");
        }
    }
    //spawning things

	//these all require sv_test - no spawning without it
	//some also require the player to have mod status
	if(sv_test)
	{
	//	Vec2f pos = blob.getPosition();
		int team = blob.getTeamNum();

		if (text_in == "!tree")
		{
			server_MakeSeed( pos, "tree_pine", 600, 1, 16 );
		}
		else if (text_in == "!btree")
		{
			server_MakeSeed( pos, "tree_bushy", 400, 2, 16 );
		}
		else if (text_in == "!stones")
		{
			CBlob@ b = server_CreateBlob( "Entities/Materials/MaterialStone.cfg", team, pos );

			if (b !is null) {
				b.server_SetQuantity(320);
			}
		}
		else if (text_in == "!arrows")
		{
			for (int i = 0; i < 3; i++)
			{
				CBlob@ b = server_CreateBlob( "Entities/Materials/MaterialArrows.cfg", team, pos );

				if (b !is null) {
					b.server_SetQuantity(30);
				}
			}
		}
		else if (text_in == "!bombs")
		{
			//  for (int i = 0; i < 3; i++)
			CBlob@ b = server_CreateBlob( "Entities/Materials/MaterialBombs.cfg", team, pos );

			if (b !is null) {
				b.server_SetQuantity(30);
			}
		}
		else if (text_in == "!spawnwater" && player.isMod())
		{
			getMap().server_setFloodWaterWorldspace(pos, true);
		}
		else if (text_in == "!seed")
		{
			// crash prevention?
		}
		else if (text_in == "!crate")
		{
			client_AddToChat( "usage: !crate BLOBNAME [DESCRIPTION]", SColor(255, 255, 0,0));
			server_MakeCrate( "", "", 0, team, Vec2f( pos.x, pos.y - 30.0f ) );
		}
		else if (text_in == "!coins")
		{
			player.server_setCoins( player.getCoins() + 100 );
		}
        else if (text_in == "!shieldbot") {
            CBlob@ knight = server_CreateBlob("knight", -1, pos);
            knight.AddScript("ShieldBot.as");
        }
        else if (text_in == "!slashbot") {
            CBlob@ knight = server_CreateBlob("knight", -1, pos);
            knight.AddScript("SlashBot.as");
        }
		else if (text_in.substr(0, 1) == "!")
		{
			// check if we have tokens
			string[]@ tokens = text_in.split(" ");

			if (tokens.length > 1)
			{
				if (tokens[0] == "!crate")
				{
					int frame = tokens[1] == "catapult" ? 1 : 0;
					string description = tokens.length > 2 ? tokens[2] : tokens[1];
					server_MakeCrate( tokens[1], description, frame, -1, Vec2f( pos.x, pos.y ) );
				}
				else if (tokens[0] == "!team")
				{
					int team = parseInt(tokens[1]);
					blob.server_setTeamNum(team);
				}
				else if (tokens[0] == "!setcoins")
				{
					int coins = parseInt(tokens[1]);
					if (coins <0) coins == 0;
					player.server_setCoins(coins);
				}
				else if (tokens[0] == "!scroll")
				{
					string s = tokens[1];
					for(uint i = 2; i < tokens.length; i++)
						s += " "+tokens[i];
					server_MakePredefinedScroll( pos, s );
				}
				else if(tokens[0] == "!train")
				{
					string mode = tokens[1];
					if(mode == "0")
					{
						CPlayer@ bot = AddBot("Bob",XORRandom(3) + 1,2);
					}
					else if(mode == "1")
					{
						CPlayer@ bot = AddBot("Bob but harder",XORRandom(3) + 1,2);
					}
					
					 
				}
				
				else 
				{
					string name = tokens[0].substr(1, tokens[0].length());
					u8 team = parseInt(tokens[1]);
					if (server_CreateBlob( name, team, pos ) is null) 
					{
						client_AddToChat( "blob " + text_in + " not found", SColor(255, 255, 0,0));
					}
				}

				return true;
			}

			// try to spawn an actor with this name !actor
			string name = text_in.substr(1, text_in.size());

			if (server_CreateBlob( name, team, pos ) is null) {
				client_AddToChat( "blob " + text_in + " not found", SColor(255, 255, 0,0));
			}
		}
	}
	
    return true;
}

bool onClientProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	if (text_in == "!help" && player is getLocalPlayer())
	{
		client_AddToChat("Captains is a gamemode where two players take turns picking players and then play CTF with some changes.", SColor(255, 180, 24, 94));
		client_AddToChat("There are admin-only commands such as:", SColor(255, 180, 24, 94));
		client_AddToChat("!lockteams - disables team changing;", SColor(255, 180, 24, 94));
		client_AddToChat("!captains <user1> <user2> - selects two team captains;", SColor(255, 180, 24, 94));
		client_AddToChat("!pick <user> - swaps a player to your team if you're a captain;", SColor(255, 180, 24, 94));
		client_AddToChat("!allspec - puts everyone to the specator team;", SColor(255, 180, 24, 94));
		client_AddToChat("!blue <user> - swaps a player to blue;", SColor(255, 180, 24, 94));
		client_AddToChat("!red <user> - swaps a player to red;", SColor(255, 180, 24, 94));
		client_AddToChat("!players <user1> <user2> - swaps user1 to blue and user2 to red;", SColor(255, 180, 24, 94));
		client_AddToChat("!spec <user> - swaps a player to the spectator team;", SColor(255, 180, 24, 94));
	}

    if (text_in == "!debug" && !getNet().isServer())
    {
        // print all blobs
        CBlob@[] all;
        getBlobs( @all );

        for (u32 i=0; i < all.length; i++)
        {
            CBlob@ blob = all[i];
            print("["+blob.getName()+" " + blob.getNetworkID() + "] ");

            if (blob.getShape() !is null)
			{
				CBlob@[] overlapping;
				if (blob.getOverlapping( @overlapping ))
				{
					for (uint i = 0; i < overlapping.length; i++)
					{
						CBlob@ overlap = overlapping[i];
						print("       " + overlap.getName() + " " + overlap.isLadder());
					}
				}
            }
        }
    }
	
	return true;
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player) 
{
	if (player.getUsername() == "among cock owo cringe")
	{
		blocked.insertLast(player.getNetworkID());
	}
}

void ChangePlayerTeam(CRules@ this, CPlayer@ player, int teamNum) {
    RulesCore@ core;
    this.get("core", @core);
    core.ChangePlayerTeam(player, teamNum);
}

int CountPlayersInTeam(int teamNum) {
    int count = 0;

    for (int i=0; i < getPlayerCount(); i++) {
        CPlayer@ p = getPlayer(i);
        if (p is null) continue;

        if (p.getTeamNum() == teamNum)
            count++;
    }

    return count;
}



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
