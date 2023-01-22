enum ButtonStates
{
	None = 0,
	Hovered,
	Selected,
	SelectedHovered
};

class StarMenu
{
	string filename;
	ClickableStar@[] starlist;
	Vec2f clickableOrigin, clickableSize;

	bool hoverdOnAny;
	bool pressedOnAny;
	int whichHovered;
	int rating;

	StarMenu(string filename)
	{
		this.filename = filename;
		clickableOrigin = Vec2f(screenMidX - 320 * scale, screenMidY);
		clickableSize = Vec2f(640 * scale, 200 * scale);

		Vec2f start = Vec2f(clickableOrigin.x + 0 * scale, clickableOrigin.y + 120 * scale);

		for(int i = 0; i < 10; ++i)
		{
			ClickableStar@ NewStar = ClickableStar(start, i);
			starlist.push_back(NewStar);

			start.x += 64 * scale;
		}

		hoverdOnAny = false;
		pressedOnAny = false;
		whichHovered = -1;
		rating = 0;
	}

	void RenderGUI(CControls@ controls)
	{
		const Vec2f TL_outline = clickableOrigin;
		const Vec2f BR_outline = clickableOrigin + clickableSize;
		GUI::DrawPane(TL_outline, BR_outline, color_white);

		GUI::SetFont("AveriaSerif-Bold_22");
		GUI::DrawTextCentered("Please rate how good this map is for Captains (from 1 to 10)", Vec2f(clickableOrigin.x + clickableSize.x / 2, clickableOrigin.y + 30 * scale), color_white);

		hoverdOnAny = false;

		Vec2f mousepos = controls.getMouseScreenPos();

		for(int i = 0; i < starlist.size(); ++i)
		{
			if(starlist[i].isHovered(mousepos)) 
			{
				hoverdOnAny = true;
			}
			starlist[i].RenderGUI();
		}

		GUI::SetFont("SourceHanSansCN-Bold_34");

		if(hoverdOnAny && !pressedOnAny)
		{
			GUI::DrawTextCentered(whichHovered + "/10", Vec2f(clickableOrigin.x + clickableSize.x / 2, clickableOrigin.y + 80 * scale), color_white);
		}
		else
		{
			GUI::DrawTextCentered(rating + "/10", Vec2f(clickableOrigin.x + clickableSize.x / 2, clickableOrigin.y + 80 * scale), SColor(255, 255, 200, 75));
		}
	}

	void Update(CControls@ controls)
	{
		for(int i = 0; i < starlist.size(); ++i)
		{
			starlist[i].Update(controls, @this);
		}
	}
}

class ClickableStar
{
	Vec2f clickableOrigin;
	Vec2f clickableSize;
	int order;
	int State;
	int frame;
	bool update;

	ClickableStar(Vec2f one, int order)
	{
		this.order = order;
		clickableOrigin = one;
		clickableSize = Vec2f(64, 64);
		frame = 1;
		State = 1;
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

	void RenderGUI()
	{
		GUI::DrawIcon("MapStars.png", frame, Vec2f(32, 32), clickableOrigin, scale, 0);
	}

	void Update(CControls@ controls, StarMenu@ starmenu)
	{
		Vec2f mousepos = controls.getMouseScreenPos();
		const bool mousePressed = controls.isKeyPressed(KEY_LBUTTON);
		const bool mouseJustReleased = controls.isKeyJustReleased(KEY_LBUTTON);

		ClickableStar@[]@ starlist = starmenu.starlist;
 
		if (this.isHovered(mousepos))
		{
			if (mouseJustReleased)
			{
				Sound::Play("select.ogg");
				starmenu.rating = order + 1;

				CPlayer@ player = getLocalPlayer();
				if(player !is null)
				{
					CBitStream params;
					params.write_string(getLocalPlayer().getUsername());
					params.write_u32(starmenu.rating);
					getRules().SendCommand(getRules().getCommandID("sync rate"), params);
				}
				starmenu.pressedOnAny = true;
				printf("v " + order);
				for (int i = 0; i < order + 1; ++i)
				{
					starlist[i].frame = 0;
					starlist[i].State = 0;
				}
				
				for (int i = order + 1; i < starlist.size(); ++i)
				{
					starlist[i].frame = 1;
					starlist[i].State = 1;
				}
			}

			if (!starmenu.pressedOnAny)
			{
				starmenu.whichHovered = order + 1;
				for (int i = 0; i < order + 1; ++i)
				{
					starlist[i].frame = 2;
				}
				
				for (int i = order + 1; i < starlist.size(); ++i)
				{
					starlist[i].frame = 1;
				}
			}
		}
		else if(!starmenu.hoverdOnAny)
		{
			starmenu.pressedOnAny = false;
			for (int i = 0; i < starlist.size(); ++i)
			{
				if(starlist[i].State == 0)
				{
					starlist[i].frame = 0;
				}
				else
				{
					starlist[i].frame = 1;
				}
			}
		}
	}
}

bool render_menu;
StarMenu ourmenu;

float screenMidX;
float screenMidY;

float scale;

void onInit(CRules@ this)
{
	if (!GUI::isFontLoaded("AveriaSerif-Bold_22"))
    {
        string AveriaSerif = CFileMatcher("AveriaSerif-Bold.ttf").getFirst();
        GUI::LoadFont("AveriaSerif-Bold_22", AveriaSerif, 22, true);
    }
    if (!GUI::isFontLoaded("SourceHanSansCN-Bold_34"))
    {
        string AveriaSerif = CFileMatcher("SourceHanSansCN-Bold.ttf").getFirst();
        GUI::LoadFont("SourceHanSansCN-Bold_34", AveriaSerif, 34, true);
    }

	render_menu = false;

	scale = 1.0f;

	screenMidX = getScreenWidth() - 340 * scale;
	screenMidY = 20 * scale;

	this.addCommandID("start map rate");
	this.addCommandID("sync rate");

	string[] usernameArray;

	this.set("username array", usernameArray);
}

void onRestart(CRules@ this)
{
	string[] usernameArray;

	this.set("username array", usernameArray);
}

void onReload(CRules@ this)
{
	onInit(this);
}

void onTick(CRules@ this)
{
	CPlayer@ player = getLocalPlayer();
	if(player is null) return;

	CControls@ controls = player.getControls();
	if(controls is null) return;

	if(render_menu && isClient() && player.isMyPlayer())
	{
		ourmenu.Update(controls);
	}

	return;
}

void onRender(CRules@ this)
{
	CPlayer@ player = getLocalPlayer();
	if(player is null) return;

	CControls@ controls = player.getControls();
	if(controls is null) return;

	if(render_menu && isClient() && player.isMyPlayer())
	{
		ourmenu.RenderGUI(controls);
	}

	return;
}

bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	if (player is null)
		return true;
	
	string[]@ tokens = text_in.split(" ");
	u8 tlen = tokens.length;
	
	if (tokens[0] == "!mapratevote" && player.getUsername() == "HomekGod") 
	{
		CBitStream params;
		params.write_bool(true);
		this.SendCommand(this.getCommandID("start map rate"), params);
	}
	if (tokens[0] == "!mapratevoteend" && player.getUsername() == "HomekGod") 
	{
		CBitStream params;
		params.write_bool(false);
		this.SendCommand(this.getCommandID("start map rate"), params);
	}

	return true;
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if(cmd == this.getCommandID("start map rate"))
	{
		bool starting = params.read_bool();

		if(starting)
		{
			render_menu = true;

			StarMenu pog("cock");

			ourmenu = pog;
		}
		else
		{
			render_menu = false;

			if(isServer())
			{
				string[] name = getMap().getMapName().split('/');	 //Official server maps seem to show up as
				string mapName = name[name.length() - 1];		 //``Maps/CTF/MapNameHere.png`` while using this instead of just the .png
				mapName = getFilenameWithoutExtension(mapName);  // Remove extension from the filename if it exists

				string[] usernameArray;
				this.get("username array", usernameArray);
				for(int i=0; i < usernameArray.size(); ++i)
				{
					printf("username: " + usernameArray[i]);
				}

				ConfigFile cfg;
	   			cfg.loadFile("../Cache/BUNMAPS/VOTEMAP_" + mapName + ".cfg");
				cfg.addArray_string("All players", usernameArray);

				for(int i=0; i < usernameArray.size(); ++i)
				{
					cfg.add_u16(usernameArray[i], this.get_u32(usernameArray[i] + "maprate"));
				}

				cfg.saveFile("BUNMAPS/VOTEMAP_" + mapName);
			}
		}
	}
	else if(cmd == this.getCommandID("sync rate"))
	{
		string username = params.read_string();
		u32 rating = params.read_u32();
		this.set_u32(username + "maprate", rating);
		
		string[] usernameArray;
		this.get("username array", usernameArray);

		if(usernameArray.find(username) == -1)
		{
			usernameArray.push_back(username);
		}
		this.set("username array", usernameArray);
	}
}