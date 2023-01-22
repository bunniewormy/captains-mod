#include "pathway.as";

const string MAP_DIR = "BUNMAPS/";

class InfoButton
{
	Vec2f clickableOrigin;
	Vec2f clickableSize;
	int rating;
	int order;
	float avg_rating;
	string[] names;
	bool hovered = true;

	InfoButton(Vec2f coc, int rat, string[] hehe, int bubu, float ura)
	{
		hovered = false;
		rating = rat;
		names = hehe;
		clickableOrigin = coc;
		clickableSize = Vec2f(60, 60);
		order = bubu;
		avg_rating = ura;
	}

	bool isHovered(Vec2f mousepos)
	{
		Vec2f tl = clickableOrigin;
		Vec2f br = clickableOrigin + clickableSize;

		if (mousepos.x > tl.x && mousepos.y > tl.y &&
		     mousepos.x < br.x && mousepos.y < br.y)
		{
			hovered = true;
			return true;
		}
		hovered = false;
		return false;
	}

	void changeOrigin(Vec2f yep)
	{
		clickableOrigin = yep;
	}

	void RenderGUI()
	{
		//const string image = "plusandminus.png";
		//GUI::DrawRectangle(clickableOrigin, Vec2f(clickableOrigin.x + clickableSize.x, clickableOrigin.y + clickableSize.y));

		int test = avg_rating + 1;
		f32 remainder = avg_rating + 1 - test;
		remainder *= 10;
		int remainderint = remainder;

		if(hovered)
		{
			GUI::DrawPane(Vec2f(screenMidX - 200, clickableOrigin.y + 110), Vec2f(screenMidX + 200, clickableOrigin.y + 690));

			GUI::DrawText("Players who rated " + rating, Vec2f(screenMidX - 180, clickableOrigin.y + 120), color_white);

			GUI::SetFont("menu");

			int y = 180;

			for(int i=0; i<names.size(); ++i)
			{
				GUI::DrawText(names[i], Vec2f(screenMidX - 180, clickableOrigin.y + y), color_white);
				y += 25;
			}
		}

		GUI::SetFont("SourceHanSansCN-Bold_34");
		if(order < test)
		{
			GUI::DrawIcon("partialstars.png", 11, Vec2f(30, 30), clickableOrigin, 1.0, 0);
		}
		else if (order > test)
		{
			GUI::DrawIcon("partialstars.png", 0, Vec2f(30, 30), clickableOrigin, 1.0, 0);
		}
		else
		{
			GUI::DrawIcon("partialstars.png", remainderint, Vec2f(30, 30), clickableOrigin, 1.0, 0);
		}

		GUI::DrawTextCentered("" + names.size(), Vec2f(clickableOrigin.x + clickableSize.x / 2, clickableOrigin.y + clickableSize.y / 2 + 40), color_white);
		//GUI::DrawIcon(image, frame, Vec2f(32, 32), clickableOrigin, 1.0f);
	}

	void Update(CControls@ controls)
	{
		Vec2f mousepos = controls.getMouseScreenPos();
		const bool mousePressed = controls.isKeyPressed(KEY_LBUTTON);
		const bool mouseJustReleased = controls.isKeyJustReleased(KEY_LBUTTON);

		if (this.isHovered(mousepos))
		{

		}
	}
}

class ClickButton
{
	Vec2f clickableOrigin;
	Vec2f clickableSize;
	int State;

	ClickButton(int cock)
	{
		clickableOrigin = Vec2f_zero;
		clickableSize = Vec2f(64, 64);
		State = cock;
	}

	bool isHovered(Vec2f mousepos)
	{
		Vec2f tl = clickableOrigin;
		Vec2f br = clickableOrigin + clickableSize;

		if (mousepos.x > tl.x && mousepos.y > tl.y &&
		     mousepos.x < br.x && mousepos.y < br.y)
		{

			return true;
		}
		return false;
	}

	void changeOrigin(Vec2f yep)
	{
		clickableOrigin = yep;
	}

	void RenderGUI()
	{
		const string image = "plusandminus.png";
		int frame;
		if(State == 0) frame = 0;
		else frame = 1;
		GUI::DrawRectangle(clickableOrigin, Vec2f(clickableOrigin.x + clickableSize.x, clickableOrigin.y + clickableSize.y));
		GUI::DrawIcon(image, frame, Vec2f(32, 32), clickableOrigin, 1.0f);
	}

	void Update(CControls@ controls)
	{
		Vec2f mousepos = controls.getMouseScreenPos();
		const bool mousePressed = controls.isKeyPressed(KEY_LBUTTON);
		const bool mouseJustReleased = controls.isKeyJustReleased(KEY_LBUTTON);

		if (this.isHovered(mousepos))
		{
			if (mouseJustReleased)
			{
				Sound::Play("select.ogg");
				if(State == 1 && client_entries.size() - 1 > current_map)
				current_map += 1;
				else if(State == 0 && current_map > 0)
				current_map -= 1;
			}
		}
	}
}

class MapRatingEntry
{
	string m_map_name; // set on sv
	string[] m_all_players; // set on sv
	u32[] m_all_ratings; // set on sv
	f32 m_avg_rating; // do on client
	string local_path; // do on client
	u32 m_width;
	u32 m_height;
	bool exists;

	string[] rate1;
	string[] rate2;
	string[] rate3;
	string[] rate4;
	string[] rate5;
	string[] rate6;
	string[] rate7;
	string[] rate8;
	string[] rate9;
	string[] rate10;

	InfoButton@[] infos;

	bool local_here;
	u32 local_id;

	MapRatingEntry(string map_name)
	{
		ConfigFile file;
		m_map_name = map_name;
		if(file.loadFile("../Cache/" + MAP_DIR + "VOTEMAP_" + map_name + ".cfg")) 
		{
			exists = true;
			file.readIntoArray_string(m_all_players, "All players");

			for(int i=0; i < m_all_players.size(); ++i)
			{
				m_all_ratings.push_back(file.read_u32(m_all_players[i]));
			}
		}
		else
		{
			exists = false;
		}
	}

	u32 getWidth()
	{
		return m_width;
	}

	u32 getHeight()
	{
		return m_height;
	}

	MapRatingEntry(CBitStream@ params)
    {
    	m_map_name = params.read_string();

    	f32 rating = 0;

    	u32 size = params.read_u32();
    	for(int i=0; i < size; ++i)
    	{
    		m_all_players.push_back(params.read_string());
    	}

    	u32 size2 = params.read_u32();
    	for(int i=0; i < size2; ++i)
    	{
    		u32 current_rating = params.read_u32();
    		m_all_ratings.push_back(current_rating);
    		rating += current_rating;
    	}

    	m_avg_rating = (rating / size2);
    	exists = true;
    	local_path = getCaptainsPath() + "Maps/Competition/" + m_map_name + ".png";

    	string prop_name = "ClientMap" + local_path;

    	Texture::createFromFile(prop_name, local_path);
		{
			ImageData@ map = Texture::data(prop_name);
			m_width = map.width();
			m_height = map.height();
		}

		if(getLocalPlayer() !is null)
		{
			if(m_all_players.find(getLocalPlayer().getUsername()) != -1)
			{
				local_here = true;
				local_id = m_all_players.find(getLocalPlayer().getUsername());
			}
		}

		for(int i=0; i < m_all_players.size(); ++i)
    	{
    		u32 current_rating = m_all_ratings[i];

    		switch(current_rating)
    		{
    			case 1:
    			rate1.push_back(m_all_players[i]);
    			break;
    			case 2:
    			rate2.push_back(m_all_players[i]);
    			break;
    			case 3:
    			rate3.push_back(m_all_players[i]);
    			break;
    			case 4:
    			rate4.push_back(m_all_players[i]);
    			break;
    			case 5:
    			rate5.push_back(m_all_players[i]);
    			break;
    			case 6:
    			rate6.push_back(m_all_players[i]);
    			break;
    			case 7:
    			rate7.push_back(m_all_players[i]);
    			break;
    			case 8:
    			rate8.push_back(m_all_players[i]);
    			break;
    			case 9:
    			rate9.push_back(m_all_players[i]);
    			break;
    			case 10:
    			rate10.push_back(m_all_players[i]);
    			break;
    			default:
    			break;
    		}
    	}

    	for(int i=0; i < 10; ++i)
    	{
    		int huhu = i + 1;

    			if(huhu == 1)
    			{
	    			Vec2f yep = Vec2f(screenMidX - 300, screenMidY + (m_height) * 2 + 100);
	    			InfoButton hey(yep, 1, rate1, i + 1, m_avg_rating);
	    			infos.push_back(hey);
	    		}
    			if(huhu == 2)
    			{
	    			Vec2f yep = Vec2f(screenMidX - 300 + 60, screenMidY + (m_height) * 2 + 100);
    				InfoButton hey(yep, 2, rate2, i + 1, m_avg_rating);
    				infos.push_back(hey); 
    			}
    			if(huhu == 3)
    			{
	    			Vec2f yep = Vec2f(screenMidX - 300 + 60 * 2, screenMidY + (m_height) * 2 + 100);
    				InfoButton hey(yep, 3, rate3, i + 1, m_avg_rating);
    				infos.push_back(hey); 
    			}
    			if(huhu == 4)
    			{
	    			Vec2f yep = Vec2f(screenMidX - 300 + 60 * 3, screenMidY + (m_height) * 2 + 100);
    			InfoButton hey(yep, 4, rate4, i + 1, m_avg_rating);
    			infos.push_back(hey); }
    			if(huhu == 5)
    			{
	    			Vec2f yep = Vec2f(screenMidX - 300 + 60 * 4, screenMidY + (m_height) * 2 + 100);
    			InfoButton hey(yep, 5, rate5, i + 1, m_avg_rating);
    			infos.push_back(hey); }
    			if(huhu == 6)
    			{
	    			Vec2f yep = Vec2f(screenMidX - 300 + 60 * 5, screenMidY + (m_height) * 2 + 100);
    			InfoButton hey(yep, 6, rate6, i + 1, m_avg_rating);
    			infos.push_back(hey); }
    			if(huhu == 7)
    			{
	    			Vec2f yep = Vec2f(screenMidX - 300 + 60 * 6, screenMidY + (m_height) * 2 + 100);
    			InfoButton hey(yep, 7, rate7, i + 1, m_avg_rating);
    			infos.push_back(hey); }
    			if(huhu == 8)
    			{
	    			Vec2f yep = Vec2f(screenMidX - 300 + 60 * 7, screenMidY + (m_height) * 2 + 100);
    			InfoButton hey(yep, 8, rate8, i + 1, m_avg_rating);
    			infos.push_back(hey); 
    			}
    			if(huhu == 9)
    			{
	    			Vec2f yep = Vec2f(screenMidX - 300 + 60 * 8, screenMidY + (m_height) * 2 + 100);
    				InfoButton hey(yep, 9, rate9, i + 1, m_avg_rating);
    				infos.push_back(hey); 
    			}
    			if(huhu == 10)
    			{
	    			Vec2f yep = Vec2f(screenMidX - 300 + 60 * 9, screenMidY + (m_height) * 2 + 100);
    				InfoButton hey(yep, 10, rate10, i + 1, m_avg_rating);
    				infos.push_back(hey); 
    			}
    	}
    }

	void serialize(CBitStream@ params)
	{
		params.write_string(m_map_name);

		params.write_u32(m_all_players.size());
		for(int i=0; i < m_all_players.size(); ++i)
		{
			params.write_string(m_all_players[i]);
		}

		params.write_u32(m_all_ratings.size());
		for(int i=0; i < m_all_ratings.size(); ++i)
		{
			params.write_u32(m_all_ratings[i]);
		}
	}

	void Render()
	{
		GUI::SetFont("SourceHanSansCN-Bold_34");

		GUI::DrawPane(Vec2f(screenMidX - (m_width * 2) - 100, screenMidY - (m_height) * 2 - 100),Vec2f(screenMidX + (m_width * 2) + 100, screenMidY + (m_height * 2) + 100));

		GUI::DrawTextCentered("Average rating: " + formatFloat(m_avg_rating, "", 0, 2) + "/10", Vec2f(screenMidX, screenMidY - (m_height) * 2 - 70), color_white);

		GUI::DrawTextCentered("Map Name: " + m_map_name, Vec2f(screenMidX, screenMidY + (m_height) * 2 + 50), color_white);

		if(local_here)
		{
			GUI::DrawTextCentered("Your rating: " + m_all_ratings[local_id] + "/10", Vec2f(screenMidX, screenMidY - (m_height) * 2 - 30), color_white);
		}

		GUI::DrawIcon(local_path, 0, Vec2f(m_width, m_height), Vec2f(screenMidX - (m_width * 2), screenMidY - (m_height * 2)), 2.0f);

		GUI::DrawPane(Vec2f(screenMidX - 300, screenMidY + (m_height) * 2 + 100), Vec2f(screenMidX - 300 + 10 * 60, screenMidY + (m_height) * 2 + 160));

		for(int i=0; i < infos.size(); ++i)
		{
			infos[i].RenderGUI();
		}
	}

	void Update(CControls@ controls)
	{
		for(int i=0; i < infos.size(); ++i)
		{
			infos[i].Update(controls);
		}
	}

	int opCmp(const MapRatingEntry &in other)
 	{
  		return m_avg_rating * 100 - other.m_avg_rating * 100;
  	}
}

MapRatingEntry[] server_entries;
MapRatingEntry[] client_entries;
ClickButton[] buttonz;

bool show_map;
u32 current_map;

void onInit(CRules@ this)
{
	if (!GUI::isFontLoaded("SourceHanSansCN-Bold_34"))
    {
        string AveriaSerif = CFileMatcher("SourceHanSansCN-Bold.ttf").getFirst();
        GUI::LoadFont("SourceHanSansCN-Bold_34", AveriaSerif, 34, true);
    }

    this.set_bool("pizzatime", false);

    buttonz.clear();
    ClickButton yep(0);
    ClickButton yep2(1);

    buttonz.push_back(yep);
   	buttonz.push_back(yep2);

   	buttonz[0].changeOrigin(Vec2f(getScreenWidth() / 2 - 300, getScreenHeight() / 12));
	buttonz[1].changeOrigin(Vec2f(getScreenWidth() / 2 + 236, getScreenHeight() / 12));

	show_map = false;
	current_map = 0;

	client_entries.clear();
	this.addCommandID("send maprate");

	string[] map_names = {
		"Comp1_123a",
		"Comp2_01repdesire",
		"Comp3_0102rep-salvation",
		"Comp4_Aojiroku",
		"Comp5_hollow",
		"Comp6_trunk",
		"Comp7_beta1",
		"Comp8_4DChess",
		"Comp9_Nibble",
		"Comp10_Disco_Inferno",
		"Comp11_beadino",
		"Comp12_Laque",
		"Comp13_get_in_the_ring",
		"Comp14_SanFrancisco",
		"Comp15_CretanBull",
		"Comp16_round_reverse_regeneration",
		"Comp17_Bowl",
		"Comp18_woodenspoon",
		"Comp19_Multi_Level_Crossing",
		"Comp20_Foolproof_Fatalism",
		"Comp21_Take_my_heart_im_lonely",
		"Comp22_We_will_kiss_in_the_moonlight",
		"Comp23_Mists",
		"Comp24_lackof",
		"Comp25_porcupine",
		"Comp26_Frost_Fragment",
		"Comp27_Voice_Universal_Nemesis",
		"Comp28_Fake_Moon_Strobe_Lights",
		"Comp29_Golden_Melancholy",
		"Comp30_More_Human_Than_Human",
		"Comp31_HARDCORE_SHUBHUMANITY",
		"Comp32_Bombeta_Island",
		"Comp33_Rosewood",
		"Comp34_Jacaranda",
		"Comp35_Gallant",
		"Comp36_Lashkar",
		"Comp37_Hypnotic",
		"Comp38_Stal3",
		"Comp39_harsh_swamp",
		"Comp40_Zzzz",
		"Comp41_Quick_Draw_Time",
		"Comp42_Archon",
		"Comp43_No_Mercy_For_Scientologists",
		"Comp44_Tallil",
		"Comp45_Totally_Transcendent",
		"Comp46_Fisherman",
		"Comp47_Esedel",
		"Comp48_Stjernestov",
		"Comp49_Ecstatic_Vibrations",
		"Comp50_You_Had_It_Comming",
		"Comp51_Trollabundin_v2",
		"Comp52_Fightclub",
		"Comp53_DarkAge"
	};

	if(isServer())
	{
		server_entries.clear();

		for(int i=0; i < map_names.length(); ++i)
		{
			MapRatingEntry entry(map_names[i]);
			if(entry.exists)
			{
				CBitStream params;
				entry.serialize(params);
				this.SendCommand(this.getCommandID("send maprate"), params);
			}
		}
	}	
	client_entries.sortDesc();
}

void onRestart(CRules@ this)
{
	onInit(this);
}

void onTick(CRules@ this)
{
	if(getLocalPlayer() is null) return;

	CControls@ controls = getLocalPlayer().getControls();
	if(controls is null) return;

	if(show_map && client_entries.size() > current_map)
	{
		client_entries[current_map].Update(controls);

		buttonz[0].Update(controls);
		buttonz[1].Update(controls);
	}

	if(client_entries.size() > current_map && this.get_bool("pizzatime") == false && getGameTime() == 150)
	{
		client_entries.sortDesc();
		this.set_bool("pizzatime", true);
	}
}

float screenMidX = getScreenWidth()/2;
float screenMidY = getScreenHeight()/3;

void onRender(CRules@ this)
{
	if(getLocalPlayer() is null) return;

	if(show_map && client_entries.size() > current_map)
	{
		client_entries[current_map].Render();

		buttonz[0].RenderGUI();
		buttonz[1].RenderGUI();
	}
}

bool onClientProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	if (player is null)
		return true;

	if (player !is getLocalPlayer()) return true;

	string[]@ tokens = text_in.split(" ");
	u8 tlen = tokens.length;

	if (tokens[0] == "!showvote")
    {
    	current_map = 0;
    	if(tlen < 2)
    	{
	    	if(!show_map)
	    	{
	    		show_map = true;
	    	}
	    	else
	    	{
	    		show_map = false;
	    	}
	    }
	    else if(tlen >= 2)
	    {
	    	show_map = true;
	    	current_map = parseInt(tokens[1]);
	    }
    }

    return true;
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if(isClient() && cmd == this.getCommandID("send maprate"))
	{
		MapRatingEntry entry(params);
		client_entries.push_back(entry);
		printf("yep: " + entry.m_map_name);
	}
}
