const string STATS_DIR = "BUNStats/";

string sortmode = "kills";

string getSortmode()
{
	CRules@ rules = getRules();

	if(!isClient()) return "kills";
	if(rules is null) return "kills";
	if(getLocalPlayer() is null) return "kills";

	return rules.get_string(getLocalPlayer().getUsername() + "sortmode");
}

f32 getKDR(u32 kills, u32 deaths)
{
	return kills / Maths::Max(f32(deaths), 1.0f);
}

// Stats class for one username. Has global kills, matches winrate and specific class kills. TODO: Matdrops, Heals
class Stats
{
	// username of player
 	string m_username;

	// matches
 	u32 m_matches_won;
 	u32 m_matches_lost;
 	f32 m_winrate;

 	// global k/d
 	u32 m_kills;
 	u32 m_deaths;
	f32 m_kdr;

 	// knight
 	u32 m_k_kills;
 	u32 m_k_deaths;
 	f32 m_k_kdr;

 	// builder
 	u32 m_b_kills;
 	u32 m_b_deaths;
 	f32 m_b_kdr;

 	// archer
 	u32 m_a_kills;
 	u32 m_a_deaths;
 	f32 m_a_kdr;

    u32 m_matdrops;

 	Stats(string username)
    {
    	ConfigFile file;
    
    	if(file.loadFile("../Cache/" + STATS_DIR + username)) 
    	{ 
    		this.m_username = username;

	    	this.m_matches_won = file.read_u32("matches_won"); 
	    	this.m_matches_lost = file.read_u32("matches_lost"); 
	    	this.m_winrate = this.m_matches_won / Maths::Max(f32(this.m_matches_won + this.m_matches_lost), 1.0f);

	    	this.m_kills = file.read_u32("kills"); 
	    	this.m_deaths = file.read_u32("deaths");
		    this.m_kdr = getKDR(this.m_kills, this.m_deaths);

	    	this.m_k_kills = file.read_u32("k_kills"); 
	    	this.m_k_deaths = file.read_u32("k_deaths"); 
	    	this.m_k_kdr = getKDR(this.m_k_kills, this.m_k_deaths);

	    	this.m_b_kills = file.read_u32("b_kills"); 
	    	this.m_b_deaths = file.read_u32("b_deaths"); 
	    	this.m_b_kdr = getKDR(this.m_b_kills, this.m_b_deaths);

	    	this.m_a_kills = file.read_u32("a_kills"); 
	    	this.m_a_deaths = file.read_u32("a_deaths"); 
	    	this.m_a_kdr = getKDR(this.m_a_kills, this.m_a_deaths);

            this.m_matdrops = file.read_u32("matdrops");
  		}
    }

    Stats(u32 a, u32 b, u32 c, u32 d, u32 e, u32 f, u32 g, u32 h, u32 i, u32 j, string username)
    {
    	this.m_kills = a;
    	this.m_deaths = b;
    	this.m_matches_won = c;
    	this.m_matches_lost = d;
    	this.m_username = username;

    	this.m_k_kills = e;
    	this.m_k_deaths = f;
    	this.m_k_kdr = this.m_k_kills / Maths::Max(f32(this.m_k_deaths), 1.0f);

    	this.m_b_kills = g;
    	this.m_b_deaths = h;
    	this.m_b_kdr = this.m_b_kills / Maths::Max(f32(this.m_b_deaths), 1.0f);

    	this.m_a_kills = i;
    	this.m_a_deaths = j;
    	this.m_a_kdr = this.m_a_kills / Maths::Max(f32(this.m_a_deaths), 1.0f);

    	this.m_kdr = this.m_kills / Maths::Max(f32(this.m_deaths), 1.0f);
	    this.m_winrate = this.m_matches_won / Maths::Max(f32(this.m_matches_won + this.m_matches_lost), 1.0f);
    }

    // without wins/losses
    Stats(u32 a, u32 b, u32 e, u32 f, u32 g, u32 h, u32 i, u32 j, u32 k_matdrops, string username)
    {
    	this.m_kills = a;
    	this.m_deaths = b;
    	this.m_username = username;

    	this.m_k_kills = e;
    	this.m_k_deaths = f;
    	this.m_k_kdr = this.m_k_kills / Maths::Max(f32(this.m_k_deaths), 1.0f);

    	this.m_b_kills = g;
    	this.m_b_deaths = h;
    	this.m_b_kdr = this.m_b_kills / Maths::Max(f32(this.m_b_deaths), 1.0f);

    	this.m_a_kills = i;
    	this.m_a_deaths = j;
    	this.m_a_kdr = this.m_a_kills / Maths::Max(f32(this.m_a_deaths), 1.0f);

    	this.m_kdr = this.m_kills / Maths::Max(f32(this.m_deaths), 1.0f);

        this.m_matdrops = k_matdrops;
    }

    Stats(CBitStream@ params)
    {
        string temp_username;
        if (!params.saferead_string(temp_username)) printf("somethings not quite right");

        u32 temp_kills;
        if (!params.saferead_u32(temp_kills)) printf("somethings not quite right");

        u32 temp_deaths;
        if (!params.saferead_u32(temp_deaths)) printf("somethings not quite right");

        u32 temp_matches_won;
        if (!params.saferead_u32(temp_matches_won)) printf("somethings not quite right");

        u32 temp_matches_lost;
        if (!params.saferead_u32(temp_matches_lost)) printf("somethings not quite right");

        u32 temp_k_kills;
        if (!params.saferead_u32(temp_k_kills)) printf("somethings not quite right");

        u32 temp_k_deaths;
        if (!params.saferead_u32(temp_k_deaths)) printf("somethings not quite right");

        u32 temp_b_kills;
        if (!params.saferead_u32(temp_b_kills)) printf("somethings not quite right");

        u32 temp_b_deaths;
        if (!params.saferead_u32(temp_b_deaths)) printf("somethings not quite right");

        u32 temp_a_kills;
        if (!params.saferead_u32(temp_a_kills)) printf("somethings not quite right");

        u32 temp_a_deaths;
        if (!params.saferead_u32(temp_a_deaths)) printf("somethings not quite right");

        u32 temp_matdrops;
        if (!params.saferead_u32(temp_matdrops)) printf("somethings not quite right");

        this.m_username = temp_username;

        this.m_kills = temp_kills;
        this.m_deaths = temp_deaths;
        this.m_matches_won = temp_matches_won;
        this.m_matches_lost = temp_matches_lost;

        this.m_k_kills = temp_k_kills;
        this.m_k_deaths = temp_k_deaths;
        this.m_k_kdr = this.m_k_kills / Maths::Max(f32(this.m_k_deaths), 1.0f);

        this.m_b_kills = temp_b_kills;
        this.m_b_deaths = temp_b_deaths;
        this.m_b_kdr = this.m_b_kills / Maths::Max(f32(this.m_b_deaths), 1.0f);

        this.m_a_kills = temp_a_kills;
        this.m_a_deaths = temp_a_deaths;
        this.m_a_kdr = this.m_a_kills / Maths::Max(f32(this.m_a_deaths), 1.0f);

        this.m_kdr = this.m_kills / Maths::Max(f32(this.m_deaths), 1.0f);
        this.m_winrate = this.m_matches_won / Maths::Max(f32(this.m_matches_won + this.m_matches_lost), 1.0f);

        this.m_matdrops = temp_matdrops;
    }
    
    void serialize(CBitStream@ params)
    {
        params.write_string(m_username);

        params.write_u32(m_kills);
        params.write_u32(m_deaths);

        params.write_u32(m_matches_won);
        params.write_u32(m_matches_lost);

        params.write_u32(m_k_kills);
        params.write_u32(m_k_deaths);

        params.write_u32(m_b_kills);
        params.write_u32(m_b_deaths);

        params.write_u32(m_a_kills);
        params.write_u32(m_a_deaths);

        params.write_u32(m_matdrops);
    }

 	int opCmp(const Stats &in other)
 	{
 		// matches
  		if(getSortmode() == "matches_won")
  			return m_matches_won - other.m_matches_won;
        if(getSortmode() == "player")
            return other.m_username.toLower().opCmp(m_username.toLower());
  		if(getSortmode() == "matches_lost")
  			return m_matches_lost - other.m_matches_lost;
  		if(getSortmode() == "winrate")
        {
            int temp_winrate = m_winrate * 100;
            int temp_winrate2 = other.m_winrate * 100;
            return temp_winrate - temp_winrate2;
  		}
  		// global
  		 if(getSortmode() == "kills")
  			return m_kills - other.m_kills;
  		if(getSortmode() == "deaths")
  			return m_deaths - other.m_deaths;
  		if(getSortmode() == "kdr")
  		{
            int temp_kdr = m_kdr * 100;
            int temp_kdr2 = other.m_kdr * 100;
            return temp_kdr - temp_kdr2;
        }
  		// knight
  		if(getSortmode() == "k_kills")
  			return m_k_kills - other.m_k_kills;
  		if(getSortmode() == "k_deaths")
  			return m_k_deaths - other.m_k_deaths;
  		if(getSortmode() == "k_kdr")
  		{
            int temp_kkdr = m_k_kdr * 100;
            int temp_kkdr2 = other.m_k_kdr * 100;
            return temp_kkdr - temp_kkdr2;
        }
  		// builder
		if(getSortmode() == "b_kills")
  			return m_b_kills - other.m_b_kills;
  		if(getSortmode() == "b_deaths")
  			return m_b_deaths - other.m_b_deaths;
  		if(getSortmode() == "b_kdr")
  		{
            int temp_bkdr = m_b_kdr * 100;
            int temp_bkdr2 = other.m_b_kdr * 100;
            return temp_bkdr - temp_bkdr2;
        }
  		// archer
  		if(getSortmode() == "a_kills")
  			return m_a_kills - other.m_a_kills;
  		if(getSortmode() == "a_deaths")
  			return m_a_deaths - other.m_a_deaths;
  		if(getSortmode() == "a_kdr")
  		{
            int temp_akdr = m_a_kdr * 100;
            int temp_akdr2 = other.m_a_kdr * 100;
            return temp_akdr - temp_akdr2;
        }

         if(getSortmode() == "matdrops")
            return m_matdrops - other.m_matdrops;

  		// default
  		return m_kills - other.m_kills;
  	}

    void printAll()
    {
        printf("------ USERNAME: " + m_username);

        printf("m_matches_won:" + m_matches_won);
        printf("m_matches_lost:" + m_matches_lost);
        printf("winrate:" + m_winrate);
        printf("m_kills" + m_kills);
        printf("m_deaths" + m_deaths);
        printf("m_kdr" + m_kdr);

        printf("m_k_kills:" + m_k_kills);
        printf("m_k_deaths:" + m_k_deaths);
        printf("m_k_kdr:" + m_k_kdr);

        printf("m_b_kills:" + m_k_kills);
        printf("m_b_deaths:" + m_k_deaths);
        printf("m_b_kdr:" + m_k_kdr);

        printf("m_a_kills:" + m_k_kills);
        printf("m_a_deaths:" + m_k_deaths);
        printf("m_a_kdr:" + m_k_kdr);

        printf("m_matdrops:" + m_matdrops);
    }
}

class CurrentMatchd
{
	u32 m_match_count;
	string m_map_name;
    u32 m_match_time = 0;

	Stats[] m_blue_stats;
	u32 m_blue_kills = 0;
	u32 m_blue_deaths = 0;

	Stats[] m_red_stats;
	u32 m_red_kills = 0;
	u32 m_red_deaths = 0;

    string m_winning_team;

    CurrentMatchd(u32 count)
    {
    	ConfigFile file;
    
    	if(file.loadFile("../Cache/" + STATS_DIR + "match" + count)) 
    	{
	    	string[] blue_players;
	    	file.readIntoArray_string(blue_players, "Blue team");

	    	if(blue_players.size() > 0)
	    	{
	    		for(int i = 0; i < blue_players.size(); ++i)
	    		{
	    			string p_user = blue_players[i];
	    			u32 p_kills = file.read_u32(p_user + "_kills");
	    			u32 p_deaths = file.read_u32(p_user + "_deaths");

	    			this.m_blue_kills += file.read_u32(p_user + "_kills");
	    			this.m_blue_deaths += file.read_u32(p_user + "_deaths");

	    			u32 p_k_kills = file.read_u32(p_user+ "_k_kills");
	    			u32 p_k_deaths = file.read_u32(p_user + "_k_deaths");

	    			u32 p_b_kills = file.read_u32(p_user+ "_b_kills");
	    			u32 p_b_deaths = file.read_u32(p_user + "_b_deaths");

	    			u32 p_a_kills = file.read_u32(p_user + "_a_kills");
	    			u32 p_a_deaths = file.read_u32(p_user + "_a_deaths");

                    u32 p_matdrops = file.read_u32(p_user + "matdrops");

	    			Stats@ temporary = Stats(p_kills, p_deaths, p_k_kills, p_k_deaths, p_b_kills, p_b_deaths, p_a_kills, p_a_deaths, p_matdrops, p_user);
	    			m_blue_stats.push_back(temporary);
	    		}
	    	}

	    	string[] red_players;
	    	file.readIntoArray_string(red_players, "Red team");

	    	if(red_players.size() > 0)
	    	{
	    		for(int i = 0; i < red_players.size(); ++i)
	    		{
	    			string p_user = red_players[i];
	    			u32 p_kills = file.read_u32(p_user + "_kills");
	    			u32 p_deaths = file.read_u32(p_user + "_deaths");

	    			this.m_red_kills += file.read_u32(p_user + "_kills");
	    			this.m_red_deaths += file.read_u32(p_user + "_deaths");

	    			u32 p_k_kills = file.read_u32(p_user + "_k_kills");
	    			u32 p_k_deaths = file.read_u32(p_user + "_k_deaths");

	    			u32 p_b_kills = file.read_u32(p_user+ "_b_kills");
	    			u32 p_b_deaths = file.read_u32(p_user + "_b_deaths");

	    			u32 p_a_kills = file.read_u32(p_user + "_a_kills");
	    			u32 p_a_deaths = file.read_u32(p_user + "_a_deaths");

                    u32 p_matdrops = file.read_u32(p_user + "matdrops");

	    			Stats@ temporary = Stats(p_kills, p_deaths, p_k_kills, p_k_deaths, p_b_kills, p_b_deaths, p_a_kills, p_a_deaths, p_matdrops, p_user);
	    			m_red_stats.push_back(temporary);
	    		}
	    	}

            m_map_name = file.read_string("Map");
            m_match_count = file.read_u32("Match number");
            m_match_time = file.read_u32("Match time");
            m_winning_team = file.read_string("Winning team");
  		}
    }

    CurrentMatchd(CBitStream@ params)
    {
        u32 match_count;
        if (!params.saferead_u32(match_count)) printf("somethings not quite right");

        string map_name;
        if (!params.saferead_string(map_name)) printf("somethings not quite right");

        u32 match_time;
        if (!params.saferead_u32(match_time)) printf("somethings not quite right");

        string winning_team;
        if (!params.saferead_string(winning_team)) printf("somethings not quite right");

        u32 blue_size;
        if (!params.saferead_u32(blue_size)) printf("somethings not quite right");

        for(int i = 0; i < blue_size; ++i)
        {
            Stats@ current = Stats(params);
            m_blue_stats.push_back(current);
        }

        u32 blue_kills;
        if (!params.saferead_u32(blue_kills)) printf("somethings not quite right");

        u32 blue_deaths;
        if (!params.saferead_u32(blue_deaths)) printf("somethings not quite right");

        u32 red_size;
        if (!params.saferead_u32(red_size)) printf("somethings not quite right");

        for(int i = 0; i < red_size; ++i)
        {
            Stats@ current = Stats(params);
            m_red_stats.push_back(current);
        }

        u32 red_kills;
        if (!params.saferead_u32(red_kills)) printf("somethings not quite right");

        u32 red_deaths;
        if (!params.saferead_u32(red_deaths)) printf("somethings not quite right");

        m_match_count = match_count;
        m_map_name = map_name;
        m_match_time = match_time;
        m_winning_team = winning_team;

        m_blue_kills = blue_kills;
        m_blue_deaths = blue_deaths;

        m_red_kills = red_kills;
        m_red_deaths = red_deaths;

    }

    void serialize(CBitStream@ params)
    {
        u32 blue_size = m_blue_stats.size();
        u32 red_size = m_red_stats.size();

        params.write_u32(m_match_count);
        params.write_string(m_map_name);
        params.write_u32(m_match_time);
        params.write_string(m_winning_team);

        params.write_u32(blue_size);

        for(int i=0; i < blue_size; ++i)
        {
            m_blue_stats[i].serialize(params);
        }
        params.write_u32(m_blue_kills);
        params.write_u32(m_blue_deaths);

        params.write_u32(red_size);

        for(int i=0; i < red_size; ++i)
        {
            m_red_stats[i].serialize(params);
        }
        params.write_u32(m_red_kills);
        params.write_u32(m_red_deaths);
    }

    void printAll()
    {
        printf("<<<<<<<<<< m_match_count: " + m_match_count);
        printf("m_map_name: " + m_map_name);
        printf("m_match_time:" + m_match_time);
        printf("blue size:" + m_blue_stats.size());
        printf("red size:" + m_red_stats.size());

        for(int i=0; i < m_blue_stats.size(); ++i)
        {
            m_blue_stats[i].printAll();
        }
        for(int i=0; i < m_red_stats.size(); ++i)
        {
            m_red_stats[i].printAll();
        }

        printf("m_blue_kills:" + m_blue_kills);
        printf("m_blue_deaths:" + m_blue_deaths);

        printf("m_red_kills:" + m_red_kills);
        printf("m_red_deaths:" + m_red_deaths);

    }
}

string sTimestamp(uint s)
{
    string ret;
    int hours = s/60/60;
    if (hours > 0)
        ret += hours + getTranslatedString("h ");

    int minutes = s/60%60;
    if (minutes < 10)
        ret += "0";

    ret += minutes + getTranslatedString("m ");

    int seconds = s%60;
    if (seconds < 10)
        ret += "0";

    ret += seconds + getTranslatedString("s ");

    return ret;
}
