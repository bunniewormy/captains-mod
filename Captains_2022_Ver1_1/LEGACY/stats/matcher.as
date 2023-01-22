//#include "pepega.as";
#include "KnightCommon.as";
#include "matchercommon.as";
#include "StatsCommon.as";

//#define CLIENT_ONLY

u32 match_count;
CurrentMatchd[] all_matches;
CurrentMatchd[] client_matches;

bool different_colour = false;
		
Vec2f temp;
Vec2f temp2;

u32 selected_int;

u32 current_match;
u32 click_time;

CPlayer@ hoveredPlayer;
Vec2f hoveredPos;

bool showlb = false;
bool fclick = false;
u32[] coords = {380, 450, 520, 590, 660, 730, 800, 870, 940, 1010, 1080, 1150, 1220, 1290};
string[] sortmodes = {"kills", "deaths", "kdr", "k_kills", "k_deaths", "k_kdr", "b_kills", "b_deaths", "b_kdr", "a_kills", "a_deaths", "a_kdr", "matdrops"};
string[] namesofstuff = {"Kills", "Deaths", "KDR", "KK", "KD", "KKDR", "BK", "BD", "BKDR", "AK", "AD", "AKDR", "MatDrops"};

u32 getMatchAmount()
{
	if(isServer())
	{
		ConfigFile file;

	   	if(file.loadFile("../Cache/" + STATS_DIR + "count")) 
	    { 
	    	match_count = file.read_u32("matches");
	    	return match_count;
	    }
	}

	return 0;
}

bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if(isClient())
	{
		if(text_in.findFirst("!set_match") != -1)
		{
			string[]@ split = text_in.split(" ");
			if(split.size() > 1)
			{
				if(parseInt(split[1]) > 0 && parseInt(split[1]) <= match_count)
				{
					current_match = parseInt(split[1]);
				}
			}
		}
		if(text_in == "!haha")
		{
			printf("CLIENT_MATCHES SIZE, onClientProcessChat: " + client_matches.size());
		}
	}

	return true;
}

void matchAdd(CRules@ this, u32 count)
{
	ConfigFile file;

	if(isServer())
	{
	   	if(file.loadFile("../Cache/" + STATS_DIR + "match" + count))
	    { 
	    	all_matches.push_back(CurrentMatchd(count));
	    }
	}
}

void matchlistCreate(CRules@ this)
{
	if(isServer())
	{
		u32 match_count = getMatchAmount();

		for(int i=1; i <= match_count; ++i)
		{
			ConfigFile file;
			if(file.loadFile("../Cache/" + STATS_DIR + "match" + i))
	   		{ 
				matchAdd(this, i);
			}
		}
	}
}

void matchlistSync(CRules@ this)
{
	if(!isServer()) return;

	CBitStream hparams;

	this.SendCommand(this.getCommandID("clear matchlist"), hparams);

	for(int i=0; i < all_matches.size(); ++i)
	{
		CBitStream bparams;
		CurrentMatchd@ current = all_matches[i];
		current.serialize(bparams);
		this.SendCommand(this.getCommandID("send match"), bparams);
	}
}

bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	if (player is null)
		return true;

    if (text_in == "!matchsync")
	{
		matchlistSync(this);
	}

	if(text_in == "!haha2")
	{
		printf("all_matches size, onServerProcessChat: " + all_matches.size());
	}

	if(text_in == "!haha3")
	{
		for(int i = 100; i < 255; i++)
		{
		  string command_name = getRules().getNameFromCommandID(i);
		  print('id '+i+':'+command_name);
		}
	}

	return true;
}

float drawMatchPlayers(Vec2f topleft, Stats[] players, CTeam@ team)
{
	CRules@ rules = getRules();
	Vec2f orig = topleft; //save for later

	f32 lineheight = 16;
	f32 padheight = 6;
	f32 stepheight = lineheight + padheight;
	Vec2f bottomright(Maths::Min(getScreenWidth() - 100, screenMidX+maxMenuWidth), topleft.y + (players.length() + 7.5) * stepheight + 10);
	GUI::DrawPane(topleft, bottomright, team.color);
	Vec2f lineoffset = Vec2f(0, -2);

	u32 underlinecolor = 0xff404040;
	u32 playercolour = 0xff808080;

	//offset border
	topleft.x += stepheight;
	bottomright.x -= stepheight;
	topleft.y += stepheight;

	GUI::SetFont("menu");

	GUI::DrawText(team.getName(), Vec2f(topleft.x, topleft.y), SColor(0xffffffff));
	topleft.y += stepheight;

	u32 total_kills = 0;
	u32 total_deaths = 0;

	for (u32 i = 0; i < players.length(); i++)
	{
		total_kills += players[i].m_kills;
		total_deaths += players[i].m_deaths;
	}

	GUI::DrawText("Total kills: " + total_kills, Vec2f(topleft.x, topleft.y), SColor(0xffffffff));
	topleft.y += stepheight;

	GUI::DrawText("Total deaths: " + total_deaths, Vec2f(topleft.x, topleft.y), SColor(0xffffffff));
	topleft.y += stepheight;

	f32 total_kdr = total_kills / Maths::Max(f32(total_deaths), 1.0f);
	GUI::DrawText("Total KDR: " + formatFloat(total_kdr, "", 0, 2), Vec2f(topleft.x, topleft.y), SColor(0xffffffff));

	topleft.y += stepheight - 5;
	bottomright.y = topleft.y + lineheight;

	GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y + 1), Vec2f(bottomright.x, bottomright.y + 1), SColor(0xffffffff));
	GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y + 1) + lineoffset, Vec2f(bottomright.x, bottomright.y + 1) + lineoffset, SColor(0xffffffff));

	topleft.y += stepheight + 5;

	if (team.getName() == "Blue Team")
	{
		temp = topleft;
	}
	else
	{
		temp2 = topleft;
	}
	string tex = "UpDown.png";

	for(int i = 0; i < namesofstuff.length(); ++i)
	{
		SColor cock_colour;

		if(selected_int == i) 
		{
			cock_colour = 0xffffEE44;
			if(!different_colour)
			{
				GUI::DrawIcon(tex, 0, Vec2f(8, 8), Vec2f(topleft.x + coords[i], topleft.y - 16), 1.0f);
			}
			else 
			{ 
				GUI::DrawIcon(tex, 1, Vec2f(8, 8), Vec2f(topleft.x + coords[i], topleft.y - 16), 1.0f);
			}
		}
		else cock_colour = 0xffffffff;

		GUI::DrawText(namesofstuff[i], Vec2f(topleft.x + coords[i], topleft.y),	cock_colour);
	}

	//draw player table header
	GUI::DrawText(getTranslatedString("Player"), Vec2f(topleft.x, topleft.y), SColor(0xffffffff));
	/*GUI::DrawText(getTranslatedString("Kills"), Vec2f(topleft.x + 380, topleft.y), SColor(0xffffffff));
	GUI::DrawText(getTranslatedString("Deaths"), Vec2f(topleft.x + 450, topleft.y), SColor(0xffffffff));
	GUI::DrawText(getTranslatedString("KDR"), Vec2f(topleft.x + 520, topleft.y), SColor(0xffffffff));
	GUI::DrawText(getTranslatedString("KK"), Vec2f(topleft.x + 590, topleft.y), SColor(0xffffffff));
	GUI::DrawText(getTranslatedString("KD"), Vec2f(topleft.x + 660, topleft.y), SColor(0xffffffff));
	GUI::DrawText(getTranslatedString("KKDR"), Vec2f(topleft.x + 730, topleft.y), SColor(0xffffffff));
	GUI::DrawText(getTranslatedString("BK"), Vec2f(topleft.x + 800, topleft.y), SColor(0xffffffff));
	GUI::DrawText(getTranslatedString("BD"), Vec2f(topleft.x + 870, topleft.y), SColor(0xffffffff));
	GUI::DrawText(getTranslatedString("BKDR"), Vec2f(topleft.x + 940, topleft.y), SColor(0xffffffff));
	GUI::DrawText(getTranslatedString("AK"), Vec2f(topleft.x + 1010, topleft.y), SColor(0xffffffff));
	GUI::DrawText(getTranslatedString("AD"), Vec2f(topleft.x + 1080, topleft.y), SColor(0xffffffff));
	GUI::DrawText(getTranslatedString("AKDR"), Vec2f(topleft.x + 1150, topleft.y), SColor(0xffffffff));
	GUI::DrawText(getTranslatedString("MatDrops"), Vec2f(topleft.x + 1220, topleft.y), SColor(0xffffffff));*/

	topleft.y += stepheight * 0.5f;

	CControls@ controls = getControls();
	Vec2f mousePos = controls.getMouseScreenPos();

	//draw players
	for (u32 i = 0; i < players.length(); i++)
	{
		Stats@ current_stat = players[i];
		string current_player = current_stat.m_username;

		topleft.y += stepheight;
		bottomright.y = topleft.y + lineheight;

		bool playerHover = mousePos.y > topleft.y && mousePos.y < topleft.y + 15;

		CPlayer@ local = getLocalPlayer();

		if (local !is null)
		{
			if(local.getUsername() == current_player)
			{
				playercolour = 0xffffEE44;
			}
			else
			{
				playercolour = 0xff808080;
			}
		}
		if (playerHover)
		{
			playercolour = 0xffcccccc;
			hoveredPos = topleft;
			hoveredPos.x = bottomright.x - 150;
		}

		GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y + 1) + lineoffset, Vec2f(bottomright.x, bottomright.y + 1) + lineoffset, SColor(underlinecolor));
		GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y) + lineoffset, bottomright + lineoffset, SColor(playercolour));

		//how much room to leave for names and clantags
		float name_buffer = 56.0f;

		//render the player + stats
		SColor namecolour = SColor(0xffffffff);

		if(local.getUsername() == current_player)
		{
			namecolour = SColor(0xffffEE44);
		}
		else
		{
			namecolour = SColor(0xffffffff);
		}


		GUI::DrawText("" + current_player, Vec2f(topleft.x, topleft.y), namecolour);

		GUI::DrawText("" + current_stat.m_kills, Vec2f(topleft.x + 380, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + current_stat.m_deaths, Vec2f(topleft.x + 450, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + formatFloat(current_stat.m_kdr, "", 0, 2), Vec2f(topleft.x + 520, topleft.y), SColor(0xffffffff));

		GUI::DrawText("" + current_stat.m_k_kills, Vec2f(topleft.x + 590, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + current_stat.m_k_deaths, Vec2f(topleft.x + 660, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + formatFloat(current_stat.m_k_kdr, "", 0, 2), Vec2f(topleft.x + 730, topleft.y), SColor(0xffffffff));

		GUI::DrawText("" + current_stat.m_b_kills, Vec2f(topleft.x + 800, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + current_stat.m_b_deaths, Vec2f(topleft.x + 870, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + formatFloat(current_stat.m_b_kdr, "", 0, 2), Vec2f(topleft.x + 940, topleft.y), SColor(0xffffffff));

		GUI::DrawText("" + current_stat.m_a_kills, Vec2f(topleft.x + 1010, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + current_stat.m_a_deaths, Vec2f(topleft.x + 1080, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + formatFloat(current_stat.m_a_kdr, "", 0, 2), Vec2f(topleft.x + 1150, topleft.y), SColor(0xffffffff));

		GUI::DrawText("" + current_stat.m_matdrops, Vec2f(topleft.x + 1220, topleft.y), SColor(0xffffffff));

	}

	return topleft.y;
}

float drawMatchInfo(Vec2f topleft, CurrentMatchd@ match)
{
	CRules@ rules = getRules();
	Vec2f orig = topleft; //save for later

	f32 lineheight = 16;
	f32 padheight = 6;
	f32 stepheight = lineheight + padheight;
	Vec2f bottomright(Maths::Min(getScreenWidth() - 100, screenMidX+maxMenuWidth), topleft.y + 8 * stepheight);
	GUI::DrawPane(topleft, bottomright, SColor(255, 211, 121, 224));

	//offset border
	topleft.x += stepheight;
	bottomright.x -= stepheight;
	topleft.y += stepheight;

	GUI::SetFont("menu");

	u32 underlinecolor = 0xff404040;
	Vec2f lineoffset = Vec2f(0, -2);

	GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y + 1) + lineoffset, Vec2f(bottomright.x, bottomright.y + 1) + lineoffset, SColor(underlinecolor));
	GUI::DrawText("Match count: " + match.m_match_count, Vec2f(topleft.x, topleft.y), SColor(0xffffffff));

	topleft.y += stepheight * 2;

	topleft.y += stepheight * 0.5f;

	CControls@ controls = getControls();
	Vec2f mousePos = controls.getMouseScreenPos();

	Vec2f orig2 = topleft; // save for later too

	for (u32 i = 0; i < 4; i++)
	{
		bottomright.y = topleft.y + lineheight;

		bool playerHover = mousePos.y > topleft.y && mousePos.y < topleft.y + 15;

		u32 playercolour = 0xff808080;

		GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y + 1) + lineoffset, Vec2f(bottomright.x, bottomright.y + 1) + lineoffset, SColor(underlinecolor));
		GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y) + lineoffset, bottomright + lineoffset, SColor(playercolour));

		topleft.y += stepheight;

		//how much room to leave for names and clantags
		float name_buffer = 56.0f;

		//render the player + stats
		SColor namecolour = SColor(0xffffffff);

		//GUI::DrawText("" + current_player, Vec2f(topleft.x, topleft.y), namecolour);

		/*
		GUI::DrawText("" + formatFloat(current_stat.m_winrate, "", 0, 2), Vec2f(topleft.x + 300, topleft.y), SColor(0xffffffff));

		GUI::DrawText("" + current_stat.m_kills, Vec2f(topleft.x + 380, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + current_stat.m_deaths, Vec2f(topleft.x + 450, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + formatFloat(current_stat.m_kdr, "", 0, 2), Vec2f(topleft.x + 520, topleft.y), SColor(0xffffffff));

		GUI::DrawText("" + current_stat.m_k_kills, Vec2f(topleft.x + 590, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + current_stat.m_k_deaths, Vec2f(topleft.x + 660, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + formatFloat(current_stat.m_k_kdr, "", 0, 2), Vec2f(topleft.x + 730, topleft.y), SColor(0xffffffff));

		GUI::DrawText("" + current_stat.m_b_kills, Vec2f(topleft.x + 800, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + current_stat.m_b_deaths, Vec2f(topleft.x + 870, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + formatFloat(current_stat.m_b_kdr, "", 0, 2), Vec2f(topleft.x + 940, topleft.y), SColor(0xffffffff));

		GUI::DrawText("" + current_stat.m_a_kills, Vec2f(topleft.x + 1010, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + current_stat.m_a_deaths, Vec2f(topleft.x + 1080, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + formatFloat(current_stat.m_a_kdr, "", 0, 2), Vec2f(topleft.x + 1150, topleft.y), SColor(0xffffffff));*/

	}

	topleft = orig2;

	GUI::DrawText("Map: " + match.m_map_name, Vec2f(topleft.x, topleft.y), SColor(0xffffffff));
	GUI::DrawText("Match time: " + sTimestamp(match.m_match_time / 30), Vec2f(topleft.x, topleft.y + stepheight), SColor(0xffffffff));
	GUI::DrawText("Winning team: " + match.m_winning_team, Vec2f(topleft.x, topleft.y + stepheight * 2), SColor(0xffffffff));

	// Did bunnie win or lose?

	SColor buncolor = SColor(0xffffffff);

	string bunnie = "Didn't play";
	for (u32 i = 0; i < match.m_blue_stats.length(); i++)
	{
		Stats@ current_stat = match.m_blue_stats[i];
		if (current_stat.m_username == "HomekGod")
		{
			if (match.m_winning_team == "Blue")
			{
				bunnie = "No";
				buncolor = SColor(0xff50DB29);
			}
			else
			{
				bunnie = "YES!";
				buncolor = SColor(0xffFF2B00);
			}
		}
	}
	for (u32 i = 0; i < match.m_red_stats.length(); i++)
	{
		Stats@ current_stat = match.m_red_stats[i];
		if (current_stat.m_username == "HomekGod")
		{
			if (match.m_winning_team == "Red")
			{
				bunnie = "No";
				buncolor = SColor(0xff50DB29);
			}
			else
			{
				bunnie = "YES!";
				buncolor = SColor(0xffFF2B00);
			}
		}
	}

	GUI::DrawText("Did bunnie lose: " + bunnie, Vec2f(topleft.x, topleft.y + stepheight * 3), buncolor);
	return topleft.y;

}

void onTick(CRules@ this)
{
	if(current_match == 0)
	current_match = 1;

	if(getGameTime() == 300)
	{
		
		all_matches.clear();
		client_matches.clear();

		if(all_matches.size() == 0) matchlistCreate(this);

		if(isServer())
			matchlistSync(this);
	}

	/*if(isClient() && getGameTime() > 300)
	{
		if(client_matches.size() == 0 && getGameTime() < 600)
		{
			CBitStream hparams;
			this.SendCommand(this.getCommandID("make it sync"), hparams);
		}
	}*/

	if(isClient())
	{
		if (getLocalPlayer() is null)
			return;

		CControls@ controls = getControls();

		if (controls is null) return;

		if (controls.isKeyJustPressed(KEY_TAB))
		{
			if(this.get_u32("tabmode") == 1) 
				this.set_u32("tabmode", 0);
			else this.set_u32("tabmode", 1);
		}

		if (controls.isKeyJustPressed(KEY_KEY_K) && controls.isKeyPressed(KEY_LSHIFT))
		{
			if(this.get_u32("tabmode") == 3) 
				this.set_u32("tabmode", 0);
			else this.set_u32("tabmode", 3);
		}

		CBlob@ localblob = getLocalPlayer().getBlob();

		CHUD@ hud = getHUD();

		if (controls.isKeyPressed(KEY_LBUTTON) && (controls.isKeyJustPressed(KEY_LBUTTON) || fclick))
		{
			Vec2f cursor = controls.getMouseScreenPos();

			if(cursor.x > e && cursor.x < e+64 && cursor.y > g && cursor.y < g+64 && current_match > 1)
			{
				if (fclick == false)
				{
					click_time = getGameTime();
					current_match -= 1;
					fclick = true;
					Sound::Play("buttonclick.ogg");
				}

				if(getGameTime() > click_time + 50 && fclick)
				{
					if (getGameTime() % 3 == 0)
					{
						current_match -= 1;
						Sound::Play("buttonclick.ogg");
					}
				}
				else if(getGameTime() > click_time + 20 && fclick)
				{
					if (getGameTime() % 4 == 0)
					{
						current_match -= 1;
						Sound::Play("buttonclick.ogg");
					}
				}
			}
			
			if(cursor.x > a && cursor.x < a+64 && cursor.y > c && cursor.y < c+64 && current_match < match_count)
			{
				if (fclick == false)
				{
					click_time = getGameTime();
					current_match += 1;
					fclick = true;
					Sound::Play("buttonclick.ogg");
				}

				if(getGameTime() > click_time + 50 && fclick)
				{
					if (getGameTime() % 3 == 0)
					{
						current_match += 1;
						Sound::Play("buttonclick.ogg");
					}
				}
				else if(getGameTime() > click_time + 20 && fclick)
				{
					if (getGameTime() % 4 == 0)
					{
						current_match += 1;
						Sound::Play("buttonclick.ogg");
					}
				}			
			}

			if(((cursor.x > a && cursor.x < a+64 && cursor.y > c && cursor.y < c+64) || (cursor.x > e && cursor.x < e+64 && cursor.y > g && cursor.y < g+64)) && (current_match <= 1 || current_match >= match_count))//(((cursor.x > a && cursor.x < a+64 && cursor.y > c && cursor.y < c+64) || (cursor.x > e && cursor.x < e+64 && cursor.y > g && cursor.y < g+64)) && (!(current_match > 1) || !(current_match < match_count)))
			{
				Sound::Play("NoAmmo.ogg", cursor, 1.0f);
			}
		}
		else
		{
			fclick = false;
		}

		if (controls.isKeyPressed(KEY_LBUTTON) && (controls.isKeyJustPressed(KEY_LBUTTON)) && this.get_u32("tabmode") == 3)
		{
			Vec2f cursor = controls.getMouseScreenPos();

			bool truetrue = ((cursor.y > temp.y - 32 && cursor.y < temp.y + 32) || (cursor.y > temp2.y - 32 && cursor.y < temp2.y + 32));

			/*u32[] coords = {200, 250, 300, 380, 450, 520, 590, 660, 730, 800, 870, 940, 1010, 1080, 1150, 1220, 1290};
			string[] sortmodes = {"matches_won", "matches_lost", "winrate", "kills", "deaths", "kdr", "k_kills", "k_deaths", "k_kdr", "b_kills", "b_deaths", "b_kdr", "a_kills", "a_deaths", "a_kdr"};
			string[] namesofstuff = {"Won", "Lost", "Winrate", "Kills", "Deaths", "KDR", "KK", "KD", "KKDR", "BK", "BD" "BKDR", "AK", "AD", "AKDR"};
*/

			u32 actual_match = current_match - 1;
			CurrentMatchd@ cock = client_matches[actual_match];

			for(int i = 0; i < sortmodes.length(); ++i)
			{
				if(cursor.x > temp.x + coords[i] && cursor.x < temp.x + coords[i + 1] && truetrue)
				{
					if(this.get_string(getLocalPlayer().getUsername() + "sortmode") == sortmodes[i])
					{
						if(different_colour)
						{
							cock.m_blue_stats.sortDesc();
							cock.m_red_stats.sortDesc();
						}
						else
						{
							cock.m_blue_stats.sortAsc();
							cock.m_red_stats.sortAsc();
						}

						Sound::Play("buttonclick.ogg");
						different_colour = !different_colour;
					}
					else
					{
						this.set_string(getLocalPlayer().getUsername() + "sortmode", sortmodes[i]);
						cock.m_blue_stats.sortDesc();
						cock.m_red_stats.sortDesc();
						Sound::Play("buttonclick.ogg");
						different_colour = false;
					}

					selected_int = i;
				}
			}
		}
	}
}

void onInit(CRules@ this)
{
	this.addCommandID("send match");
	this.addCommandID("clear matchlist");
	this.addCommandID("make it sync");

	matchlistCreate(this);
	
	if(isServer())
	{
		matchlistSync(this);
	}

	if(all_matches.length() > 0)
	{
		current_match = 1;
	}
}

void onReload(CRules@ this)
{
	onInit(this);
}

void onRestart(CRules@ this)
{
	/*all_matches.clear();
	client_matches.clear();*/

	if(all_matches.size() == 0) matchlistCreate(this);

	if(isServer())
		matchlistSync(this);
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if(all_matches.size() == 0) matchlistCreate(this);

	CBitStream hparams;
	this.SendCommand(this.getCommandID("make it sync"), hparams);

	if(isServer())
	{
		//matchlistSync(this);
	}
}

void onRender(CRules@ this)
{
	if (getLocalPlayer() is null || this.get_u32("tabmode") != 3)
		return;

	const string image = "plusandminus.png";

	GUI::DrawRectangle(Vec2f(e, g), Vec2f(e+64, g+64));
	GUI::DrawIcon(image, 0, Vec2f(32, 32), Vec2f(e, g), 1.0f);

	GUI::DrawRectangle(Vec2f(a, c), Vec2f(a+64, c+64));
	GUI::DrawIcon(image, 1, Vec2f(32, 32), Vec2f(a, c), 1.0f);

	GUI::DrawText("Current match: " + current_match, Vec2f(96, 156), color_white);

	Vec2f orig = topleft;

	topleft = Vec2f(Maths::Max( 100, screenMidX-maxMenuWidth), 150);

	topleft.y -= scrollOffset;

	u32 actual_match = current_match - 1;

	if(client_matches.length() > 0 && actual_match < match_count)
	{
		topleft.y = drawMatchInfo(topleft, client_matches[actual_match]);
		topleft.y += 120;
	}
	else
		return;

	if(client_matches[actual_match].m_blue_stats.length() > 0)
	{
		topleft.y = drawMatchPlayers(topleft, client_matches[actual_match].m_blue_stats, this.getTeam(0));
		topleft.y += 52;
	}

	if(client_matches[actual_match].m_red_stats.length() > 0)
	{
		topleft.y = drawMatchPlayers(topleft, client_matches[actual_match].m_red_stats, this.getTeam(1));
	}

	topleft = orig;
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if(isClient())
	{
		if (cmd == this.getCommandID("send match"))
		{
			//CurrentMatchd@ current = Stats(temp_kills, temp_deaths, temp_matches_won, temp_matches_lost, temp_k_kills, temp_k_deaths, temp_b_kills, temp_b_deaths, temp_a_kills, temp_a_deaths, temp_username);
			CurrentMatchd@ current = CurrentMatchd(params);
			client_matches.push_back(current);

			match_count = client_matches.size();
		}

		if(cmd == this.getCommandID("clear matchlist"))
		{
			client_matches.clear();
		}
	}
	if(isServer())
	{
		if (cmd == this.getCommandID("make it sync"))
		{
			matchlistSync(this);
		}
	}
}