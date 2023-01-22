#include "SuddenDeathEventsCommon.as";

int hidebuttonid = 0;

enum ButtonStates
{
	None = 0,
	Hovered,
	Selected,
	SelectedHovered
};

class ClickableButton
{
	string m_text;
	Vec2f clickableOrigin, clickableSize;
	int State;
	bool Selected;
	bool Hovered;
	Vec2f textPlace;
	string globaltext;
	Icon icon;
	u8 cmdid;
	f32 scale;
	bool deselectOthers;
	bool clickable;

	ClickableButton(string text, Vec2f clickableOrigin, Vec2f clickableSize, Icon@ icon, u8 id, f32 scale, bool des=true, bool clickable=true)
	{
		this.m_text = text;
		this.clickableOrigin = clickableOrigin;
		this.clickableSize = clickableSize;
		this.State = 0;
		this.Selected = false;
		this.Hovered = false;
		this.textPlace = Vec2f_zero;
		this.icon = icon;
		this.cmdid = id;
		this.scale = scale;
		this.deselectOthers = des;
		this.clickable = clickable;
	}

	void changePlace(Vec2f one, Vec2f two)
	{
		this.clickableOrigin = one;
		this.clickableSize = two;
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

	void setTextPlace(Vec2f textVec)
	{
		textPlace = textVec;
	}

	void setGlobalText(string settext)
	{
		globaltext = settext;
	}

	void RenderGUI()
	{
		SColor col;
		switch (State)
		{
			case ButtonStates::Hovered: col = SColor(255, 220, 220, 220); break;
			//case ButtonStates::Pressed: col = SColor(255, 200, 200, 200); break;
			case ButtonStates::Selected: col = SColor(255, 100, 255, 100); break;
			case ButtonStates::SelectedHovered: col = SColor(255, 45, 200, 45); break;
			//case ButtonStates::WonVote: col = SColor(255, 0, 255, 255); break;
			default: col = color_white;
		}

		const Vec2f TL_outline = clickableOrigin;
		const Vec2f BR_outline = clickableOrigin + clickableSize;
		GUI::DrawPane(TL_outline, BR_outline, col);
		//GUI::DrawWindow(TL_window, BR_window);

		Vec2f NameMid;

		if (textPlace == Vec2f_zero)
		{
			NameMid = Vec2f(
				clickableOrigin.x + clickableSize.x / 2,
				clickableOrigin.y + clickableSize.y - 24 * scale
			);
		}

		GUI::DrawTextCentered(m_text, NameMid, color_white);

		const Vec2f IconOffset = Vec2f(
				clickableOrigin.x + (clickableSize.x / 2 - 32 * scale),
				clickableOrigin.y + (clickableSize.y / 2 - 32 * scale)
			);

		GUI::DrawIcon(icon.texture, icon.frame, Vec2f(icon.x,icon.y), IconOffset, scale, 0);
	}

	void Update(CControls@ controls)
	{
		Vec2f mousepos = controls.getMouseScreenPos();
		const bool mousePressed = controls.isKeyPressed(KEY_LBUTTON);
		const bool mouseJustReleased = controls.isKeyJustReleased(KEY_LBUTTON);

		if (this.isHovered(mousepos))
		{
			Hovered = true;
			int currentState = this.State;

			if(this.State == ButtonStates::None)
			{
				this.State = ButtonStates::Hovered; 
				Sound::Play("select.ogg");
			}
			else

			if(this.State == ButtonStates::Selected)
			{
				this.State = ButtonStates::SelectedHovered; 
				Sound::Play("select.ogg");
			}

			if (mouseJustReleased && this.clickable)
			{
				if (Selected)
				{
					this.State = ButtonStates::None;
					CBitStream params;
					params.write_u16(cmdid);
					params.write_bool(false);
					Selected = false;
					if (cmdid == hidebuttonid && getLocalPlayer() !is null)
					{
						if(getLocalPlayer().isMyPlayer())
						{
							for(int i=0; i < button_array.size(); ++i)
							{
								ClickableButton@ CurrentButton = button_array[i];
								if(CurrentButton.cmdid != 0) continue;

								float scale = getScreenWidth() >= 2560 ? 2.0f : 1.0f;

								hidec = false;
								if(show)
								{
									CurrentButton.changePlace(Vec2f(screenMidX - 120 * scale, screenMidY + 8 * scale), Vec2f(48 * scale, 48 * scale));
								}
								else if(show2)
								{
									CurrentButton.changePlace(Vec2f(screenMidX - 220 * scale, screenMidY + 8 * scale), Vec2f(48 * scale, 48 * scale));
								}
							}
							//Selected = false;
						}
					}
					else if(cmdid != hidebuttonid)
					{

						getRules().SendCommand(getRules().getCommandID("button id"), params);
					}
				}
				else
				{
					if (cmdid != hidebuttonid && deselectOthers)
					{
						for(int i=0; i < button_array.size(); ++i)
						{
							button_array[i].Deselect();
						}
					}

					if (cmdid != hidebuttonid && show && getLocalPlayer().isMyPlayer())
					{
						for(int i=0; i < button_array.size(); ++i)
						{
							if(button_array[i].cmdid == hidebuttonid)
							{
								CBitStream paramsd;
								button_array[i].Selected = true;

								for(int i=0; i < button_array.size(); ++i)
								{
									ClickableButton@ CurrentButton = button_array[i];
									if(CurrentButton.cmdid != 0) continue;

									float scale = getScreenWidth() >= 2560 ? 2.0f : 1.0f;

									hidec = true;
									CurrentButton.changePlace(Vec2f(getScreenWidth() - 60 * scale, 15 * scale), Vec2f(48 * scale, 48 * scale));
								}
								Hovered = false;
							}
						}
					}

					CBitStream params;
					params.write_u16(cmdid);
					params.write_bool(true);
					this.State = ButtonStates::Selected;
					Selected = true;
					if (cmdid == hidebuttonid && getLocalPlayer() !is null)
					{
						if(getLocalPlayer().isMyPlayer())
						{
							for(int i=0; i < button_array.size(); ++i)
							{
								ClickableButton@ CurrentButton = button_array[i];
								if(CurrentButton.cmdid != 0) continue;

								float scale = getScreenWidth() >= 2560 ? 2.0f : 1.0f;

								hidec = true;
								CurrentButton.changePlace(Vec2f(getScreenWidth() - 60 * scale, 15 * scale), Vec2f(48 * scale, 48 * scale));
							}
							//Selected = false;
						}
					}
					else if(cmdid != hidebuttonid)
					{
						getRules().SendCommand(getRules().getCommandID("button id"), params);
					}
				}
			}
		}
		else
		{
			Hovered = false;
			this.State = (Selected ? ButtonStates::Selected : ButtonStates::None);
		}
	}

	void Deselect()
	{
		if(Selected != true) return;
		this.State = ButtonStates::None;
		Selected = false;
		CBitStream params;
		params.write_u16(cmdid);
		params.write_bool(false);
		getRules().SendCommand(getRules().getCommandID("button id"), params);
	}
}

float screenMidX = getScreenWidth() - getScreenWidth()/8;
float screenMidY = getScreenHeight() / 12;

ClickableButton[] button_array;
SuddenDeathEvent@[] event_votes;
bool show;
bool show2;
bool hidec;
bool hidec2;

ClickableButton[] active_event_buttons;

string currently_shown_text;

u32 voteLength = 40 * getTicksASecond();
u32 vote2Length = 60 * getTicksASecond();

void onInit(CRules@ this)
{
	this.addCommandID("activate vote 1");
	this.addCommandID("end vote 1");
	this.addCommandID("sync end vote 1");
	this.addCommandID("activate vote 2");
	this.addCommandID("sync vote 2");
	this.addCommandID("end vote 2");
	this.addCommandID("sync end vote 2");

	this.addCommandID("sync all events");

	this.addCommandID("do nothing");

	show = false;
	show2 = false;
	hidec = false;
	hidec2 = false;

	this.addCommandID("button id 0");
	this.addCommandID("button id");

	onRestart(this);
}

void onRestart(CRules@ this)
{
	for(int i=1; i < 7; ++i)
	{
		this.set_u16("votes for id " + i, 0);
	}
	show = false;
	show2 = false;
	hidec = false;
	hidec2 = false;
	button_array.clear();
	active_event_buttons.clear();
	this.set_u32("vote1endtime", 1);
	this.set_u32("vote2endtime", 1);
}

void onNewPlayerJoin(CRules@ this,CPlayer@ player )
{
	if(isServer())
	{
		this.Sync("votes to pass", true);
		for(int i=1; i < 7; ++i)
		{
			this.Sync("votes for id " + i, true);
		}
		this.Sync("vote1endtime", true);
		this.Sync("vote2endtime", true);

		SuddenDeathEvent@[] @events_active;
		if (!this.get("sudden_death_events_active", @events_active)) return;

		for(int i=0; i < events_active.size(); ++i)
		{
			CBitStream params;
			params.write_string(player.getUsername());
			params.write_string(events_active[i].name);
			this.SendCommand(this.getCommandID("sync all events"), params);
		}
	}
}

void onTick(CRules@ this)
{
	if(isServer())
	{
		// activate at:
		// 1h
		// 1.5h
		// 2h
		if(getGameTime() == 30 * 60 * 60 || getGameTime() == 30 * 60 * 90 || getGameTime() == 30 * 60 * 120) 
		{
			CBitStream params;
			this.SendCommand(this.getCommandID("activate vote 1"), params);
		}

		if(getGameTime() > this.get_u32("vote1endtime") && show)
		{
			CBitStream params;
			params.write_u16(this.get_u16("votes for id 1"));
			params.write_u16(this.get_u16("votes for id 2"));
			this.SendCommand(this.getCommandID("end vote 1"), params);
		}
		else if(getGameTime() > this.get_u32("vote2endtime") && show2)
		{
			CBitStream params;
			params.write_u16(this.get_u16("votes for id 1"));
			params.write_u16(this.get_u16("votes for id 2"));
			params.write_u16(this.get_u16("votes for id 3"));
			params.write_u16(this.get_u16("votes for id 4"));
			params.write_u16(this.get_u16("votes for id 5"));
			this.SendCommand(this.getCommandID("end vote 2"), params);
		}
	}

	if(isClient())
	{
		if(getGameTime() > this.get_u32("vote1endtime") && show)
		{
			show = false;
			hidec = false;
			button_array.clear();
		}
		else if(getGameTime() > this.get_u32("vote2endtime") && show2)
		{
			show2 = false;
			hidec = false;
			button_array.clear();
		}
	}

	CPlayer@ player = getLocalPlayer();
	if(player is null) return;

	CControls@ controls = player.getControls();
	if(controls is null) return;

	if(player.getTeamNum() != 0 && player.getTeamNum() != 1) return;

	if(show || show2)
	{
		if(hidec)
		{
			for(int i=0; i < button_array.size(); ++i)
			{
				ClickableButton@ CurrentButton = button_array[i];
				if(CurrentButton.cmdid == 0) CurrentButton.Update(controls);
			}
		}
		else
		{
			for(int i=0; i < button_array.size(); ++i)
			{
				ClickableButton@ CurrentButton = button_array[i];
				CurrentButton.Update(controls);
			}
		}
	}
}

void onRender(CRules@ this)
{
	CPlayer@ player = getLocalPlayer();
	if(player is null) return;

	CControls@ controls = player.getControls();
	if(controls is null) return;

	bool hoveredOnAny = false;

	if(show)
	{
		if(hidec)
		{
			for(int i=0; i < button_array.size(); ++i)
			{
				ClickableButton@ CurrentButton = button_array[i];
				if(CurrentButton.cmdid == 0) CurrentButton.RenderGUI();
				if(CurrentButton.Hovered)
				{
					hoveredOnAny = true;
					currently_shown_text = "Show Vote";
				}

				if(!hoveredOnAny)
				{
					u32 secs = ((this.get_u32("vote1endtime") + 1 - getGameTime()) / getTicksASecond()) + 1;
					string timetext = secs + "s";
					currently_shown_text = timetext + " - Y:N " + this.get_u16("votes for id 1") + ":" + this.get_u16("votes for id 2");
				}
			}

			if(button_array.size() > 0)
			{
				float scale = getScreenWidth() >= 2560 ? 2.0f : 1.0f;
				int a = 8 * scale;
				int az = 120 * scale;
				int b = 25 * scale;
				int h = 40 * scale;
				int v = 120 * scale;

				if(scale == 2.0) 
				{
					v = 180;
				}

				Vec2f dim;
				GUI::GetTextDimensions(currently_shown_text, dim);
				dim.x += 20;
				dim.y += 20;
				GUI::DrawPane(Vec2f(getScreenWidth() - v - (dim.x / 2), h - (dim.y / 2)), Vec2f(getScreenWidth() - v + (dim.x / 2), h + (dim.y / 2)));
				dim.x -= 20;
				dim.y -= 20;
				GUI::DrawText(currently_shown_text, Vec2f(getScreenWidth() - v - (dim.x / 2), h - (dim.y / 2)), Vec2f(getScreenWidth() - v + (dim.x / 2), h + (dim.y / 2)), color_white, true, true);
			}
		}
		else
		{
			for(int i=0; i < button_array.size(); ++i)
			{
				ClickableButton@ CurrentButton = button_array[i];
				CurrentButton.RenderGUI();
				if(CurrentButton.Hovered)
				{
					hoveredOnAny = true;
					currently_shown_text = CurrentButton.globaltext;
				}
			}

			if(!hoveredOnAny)
			{
				currently_shown_text = "Activate Sudden Death vote?";
			}

			if(button_array.size() > 0)
			{
				float scale = getScreenWidth() >= 2560 ? 2.0f : 1.0f;
				int a = 75 * scale;
				int b = 15 * scale;
				int c = 16 * scale;
				int d = 100 * scale;
				int e = 40 * scale;

				Vec2f dim;
				GUI::GetTextDimensions(currently_shown_text, dim);
				dim.x += 20;
				dim.y += 20;
				GUI::DrawPane(Vec2f(screenMidX - (dim.x / 2), screenMidY + a - (dim.y / 2)), Vec2f(screenMidX + (dim.x / 2), screenMidY + a + (dim.y / 2)));
				dim.x -= 20;
				dim.y -= 20;
				GUI::DrawText(currently_shown_text, Vec2f(screenMidX - (dim.x / 2), screenMidY + a - (dim.y / 2)), Vec2f(screenMidX + (dim.x / 2), screenMidY + a + (dim.y / 2)), color_white, true, true);

				u32 secs = ((this.get_u32("vote1endtime") + 1 - getGameTime()) / getTicksASecond()) + 1;
				string timetext = "Vote ends in: " + secs + "s";
				Vec2f dim2;
				GUI::GetTextDimensions(timetext, dim2);
				dim2.x += 20;
				dim2.y += 20;
				GUI::DrawPane(Vec2f(screenMidX - (dim2.x / 2), screenMidY - b - (dim2.y / 2)), Vec2f(screenMidX + (dim2.x / 2), screenMidY - b + (dim2.y / 2)));
				dim2.x -= 20;
				dim2.y -= 20;
				GUI::DrawText(timetext, Vec2f(screenMidX - (dim2.x / 2), screenMidY - b - (dim2.y / 2)), Vec2f(screenMidX + (dim2.x / 2), screenMidY - b + (dim2.y / 2)), color_white, true, true);

				if(scale == 2.0f)
				{
					int f = 35 * scale;
					int g = 95 * scale;

					string yestext = "Votes in favour: " + this.get_u16("votes for id 1");
					Vec2f dim3;
					GUI::GetTextDimensions(yestext, dim3);
					dim3.x += 20;
					dim3.y += 20;
					GUI::DrawPane(Vec2f(screenMidX - f - (dim3.x / 2), screenMidY + g - (dim3.y / 2)), Vec2f(screenMidX - f + (dim3.x / 2), screenMidY + g + (dim3.y / 2)));
					dim3.x -= 20;
					dim3.y -= 20;
					GUI::DrawText(yestext, Vec2f(screenMidX - f - (dim3.x / 2), screenMidY + g - (dim3.y / 2)), Vec2f(screenMidX - f + (dim3.x / 2), screenMidY + g + (dim3.y / 2)), color_white, true, true);

					string notext = "Votes against: " + this.get_u16("votes for id 2");
					Vec2f dim4;
					GUI::GetTextDimensions(notext, dim4);
					dim4.x += 20;
					dim4.y += 20;
					GUI::DrawPane(Vec2f(screenMidX + f - (dim4.x / 2), screenMidY + g - (dim4.y / 2)), Vec2f(screenMidX + f + (dim4.x / 2), screenMidY + g + (dim4.y / 2)));
					dim4.x -= 20;
					dim4.y -= 20;
					GUI::DrawText(notext, Vec2f(screenMidX + f - (dim4.x / 2), screenMidY + g - (dim4.y / 2)), Vec2f(screenMidX + f + (dim4.x / 2), screenMidY + g + (dim4.y / 2)), color_white, true, true);
				}
				else
				{
					int f = 70 * scale;
					int g = 110 * scale;

					string yestext = "Votes in favour: " + this.get_u16("votes for id 1");
					Vec2f dim3;
					GUI::GetTextDimensions(yestext, dim3);
					dim3.x += 20;
					dim3.y += 20;
					GUI::DrawPane(Vec2f(screenMidX - f - (dim3.x / 2), screenMidY + g - (dim3.y / 2)), Vec2f(screenMidX - f + (dim3.x / 2), screenMidY + g + (dim3.y / 2)));
					dim3.x -= 20;
					dim3.y -= 20;
					GUI::DrawText(yestext, Vec2f(screenMidX - f - (dim3.x / 2), screenMidY + g - (dim3.y / 2)), Vec2f(screenMidX - f + (dim3.x / 2), screenMidY + g + (dim3.y / 2)), color_white, true, true);

					string notext = "Votes against: " + this.get_u16("votes for id 2");
					Vec2f dim4;
					GUI::GetTextDimensions(notext, dim4);
					dim4.x += 20;
					dim4.y += 20;
					GUI::DrawPane(Vec2f(screenMidX + f - (dim4.x / 2), screenMidY + g - (dim4.y / 2)), Vec2f(screenMidX + f + (dim4.x / 2), screenMidY + g + (dim4.y / 2)));
					dim4.x -= 20;
					dim4.y -= 20;
					GUI::DrawText(notext, Vec2f(screenMidX + f - (dim4.x / 2), screenMidY + g - (dim4.y / 2)), Vec2f(screenMidX + f + (dim4.x / 2), screenMidY + g + (dim4.y / 2)), color_white, true, true);
				}
			}
		}
	}
	else if(show2)
	{
		if(hidec)
		{
			for(int i=0; i < button_array.size(); ++i)
			{
				ClickableButton@ CurrentButton = button_array[i];
				if(CurrentButton.cmdid == 0) CurrentButton.RenderGUI();
				if(CurrentButton.Hovered)
				{
					hoveredOnAny = true;
					currently_shown_text = "Show Vote";
				}

				if(!hoveredOnAny)
				{
					u32 secs = ((this.get_u32("vote1endtime") + 1 - getGameTime()) / getTicksASecond()) + 1;
					string timetext = secs + "s";
					currently_shown_text = timetext;
				}
			}
		}
		else
		{
			for(int i=0; i < button_array.size(); ++i)
			{
				ClickableButton@ CurrentButton = button_array[i];
				CurrentButton.RenderGUI();
				if(CurrentButton.Hovered)
				{
					hoveredOnAny = true;
					currently_shown_text = CurrentButton.globaltext;
				}
			}
			if(!hoveredOnAny)
			{
				currently_shown_text = "Vote on which modifier to activate";
			}
			for(int i=1; i < button_array.size(); ++i)
			{
				ClickableButton@ CurrentButton = button_array[i];
				Vec2f another = CurrentButton.clickableOrigin;
				Vec2f size = CurrentButton.clickableSize;
				float scale = getScreenWidth() >= 2560 ? 2.0f : 1.0f;

				int requiredcount = getAllTeamPlayersCount() / 2;

				SColor colord;

				if(this.get_u16("votes for id " + i) >= getRules().get_u32("votes to pass"))
				{
					colord = SColor(255, 100, 255, 100);
				}
				else
				{
					colord = SColor(255, 200, 10, 60);
				}

				string votecount = "Votes: " + this.get_u16("votes for id " + i);
				string requiredstr = "To pass: " + (getRules().get_u32("votes to pass"));

				if(scale == 1.0f)
				{
					votecount = "" + this.get_u16("votes for id " + i);
					requiredstr = "MIN: " + (getRules().get_u32("votes to pass"));
				}
				Vec2f dim;
				GUI::DrawPane(Vec2f(another.x, another.y + 64 * scale), Vec2f(another.x + size.x, another.y + 64 * scale + size.y / 2));
				GUI::DrawTextCentered(votecount, Vec2f(another.x + size.x / 2, another.y + 64 * scale + size.y / 6), colord);
				GUI::DrawTextCentered(requiredstr, Vec2f(another.x + size.x / 2, another.y + 64 * scale + size.y / 3), colord);
			}

			if(button_array.size() > 0)
			{
				float scale = getScreenWidth() >= 2560 ? 2.0f : 1.0f;
				int a = 120 * scale;
				int b = 15 * scale;
				int c = 16 * scale;
				int d = 100 * scale;
				int e = 40 * scale;

				Vec2f dim;
				GUI::GetTextDimensions(currently_shown_text, dim);
				dim.x += 20;
				dim.y += 20;
				GUI::DrawPane(Vec2f(screenMidX - (dim.x / 2), screenMidY + a - (dim.y / 2)), Vec2f(screenMidX + (dim.x / 2), screenMidY + a + (dim.y / 2)));
				dim.x -= 20;
				dim.y -= 20;
				GUI::DrawText(currently_shown_text, Vec2f(screenMidX - (dim.x / 2), screenMidY + a - (dim.y / 2)), Vec2f(screenMidX + (dim.x / 2), screenMidY + a + (dim.y / 2)), color_white, true, true);

				u32 secs = ((this.get_u32("vote2endtime") + 1 - getGameTime()) / getTicksASecond()) + 1;
				string timetext = "Vote ends in: " + secs + "s";
				Vec2f dim2;
				GUI::GetTextDimensions(timetext, dim2);
				dim2.x += 20;
				dim2.y += 20;
				GUI::DrawPane(Vec2f(screenMidX - (dim2.x / 2), screenMidY - b - (dim2.y / 2)), Vec2f(screenMidX + (dim2.x / 2), screenMidY - b + (dim2.y / 2)));
				dim2.x -= 20;
				dim2.y -= 20;
				GUI::DrawText(timetext, Vec2f(screenMidX - (dim2.x / 2), screenMidY - b - (dim2.y / 2)), Vec2f(screenMidX + (dim2.x / 2), screenMidY - b + (dim2.y / 2)), color_white, true, true);
			}
		}
	}
}

int getAllTeamPlayersCount()
{
	int a=0;

	CRules@ rules = getRules();

	for (int i=0; i < getPlayerCount(); i++) 
	{
		CPlayer@ p = getPlayer(i);
		if (p is null) continue;

		if (p.getTeamNum() == 1 || p.getTeamNum() == 0) ++a;
	}

	return a;
}

bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	if (player is null)
		return true;
	
	string[]@ tokens = text_in.split(" ");
	u8 tlen = tokens.length;
	
	if (tokens[0] == "!startvote" && player.getUsername() == "HomekGod") 
	{
		CBitStream params;
		this.SendCommand(this.getCommandID("activate vote 1"), params);
	}

	return true;
}

bool onClientProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	if (player is null)
		return true;

	if (player !is getLocalPlayer()) return true;

	string[]@ tokens = text_in.split(" ");
	u8 tlen = tokens.length;

	if (tokens[0] == "!vote")
    {
    	if(button_array.size() > 1)
    	show = true;
    }

    return true;
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if(cmd == this.getCommandID("activate vote 1"))
	{
		for(int i=1; i < 12; ++i)
		{
			this.set_u16("votes for id " + i, 0);
		}

		float scale = getScreenWidth() >= 2560 ? 2.0f : 1.0f;

		show = true;
		hidec = false;
		this.set_u32("vote1endtime", getGameTime() + voteLength);
		this.Sync("vote1endtime", true);

		Icon icon1("MenuItems.png", 28, 32, 32);
		ClickableButton cocker("", Vec2f(screenMidX - 64 * scale, screenMidY), Vec2f(64 * scale, 64 * scale), icon1, 1, scale);
		cocker.setGlobalText("Yes");

		Icon icon2("MenuItems.png", 29, 32, 32);
		ClickableButton cocker2("", Vec2f(screenMidX, screenMidY), Vec2f(64 * scale, 64 * scale), icon2, 2, scale);
		cocker2.setGlobalText("No");

		Icon icon3("MenuItems.png", 2, 32, 32);
		ClickableButton cocker3("", Vec2f(screenMidX - 120 * scale, screenMidY + 8 * scale), Vec2f(48 * scale, 48 * scale), icon3, 0, scale);
		cocker3.setGlobalText("HIDE VOTING");

		button_array.push_back(cocker);
		button_array.push_back(cocker2);
		button_array.push_back(cocker3);

		if(isClient())
		{
			client_AddToChat("VOTE STARTED: Activate sudden death modifier vote? (need 60% to pass)", SColor(255, 50, 130, 80));
		}
	}
	else if(cmd == this.getCommandID("end vote 1") && isServer())
	{
		u16 favour = params.read_u16();
		u16 against = params.read_u16();
		CBitStream paramsf;
		paramsf.write_u16(favour);
		paramsf.write_u16(against);

		getRules().SendCommand(getRules().getCommandID("sync end vote 1"), paramsf);

		show = false;
		hidec = false;
		button_array.clear();

		if(isClient())
		{
			client_AddToChat("Results of sudden death vote - in favour: " + favour + ", against: " + against, SColor(255, 50, 130, 80));
		}

		f32 percentage = f32(favour) / Maths::Max(f32(favour + against), 1.0f);;
		if (percentage >= 0.6 && favour >=1)
		{
			hidec = false;
			hidec2 = false;

			CBitStream params;
			getRules().set_u32("votes to pass", getAllTeamPlayersCount() / 2 + 1);
			getRules().Sync("votes to pass", true);
			getRules().SendCommand(getRules().getCommandID("activate vote 2"), params);
		}
	}
	else if(cmd == this.getCommandID("sync end vote 1") && isClient() && !isServer())
	{
		u16 favour = params.read_u16();
		u16 against = params.read_u16();
		show = false;
		hidec = false;
		button_array.clear();

		if(isClient())
		{
			client_AddToChat("Results of sudden death vote - in favour: " + favour + ", against: " + against, SColor(255, 50, 130, 80));
		}

		f32 percentage = f32(favour) / Maths::Max(f32(favour + against), 1.0f);;
		if (percentage >= 0.6 && favour >=1)
		{
			hidec = false;
			hidec2 = false;

			client_AddToChat(formatFloat(percentage * 100, "", 0, 2) + "% voted in favour (60% or more) - vote passed. Activating Sudden Death modifier vote", SColor(255, 50, 130, 80));
		}
		else
		{
			client_AddToChat(formatFloat(percentage * 100, "", 0, 2) + "% voted in favour (less than 60%) - vote didn't pass", SColor(255, 50, 130, 80));
		}
	}
	else if(cmd == this.getCommandID("activate vote 2") && isServer())
	{
		for(int i=1; i < 12; ++i)
		{
			this.set_u16("votes for id " + i, 0);
		}

		event_votes.clear();

		float scale = getScreenWidth() >= 2560 ? 2.0f : 1.0f;

		button_array.clear();
		show = false;
		show2 = true;
		hidec = false;
		if(isServer() && isClient())
		{
			screenMidX -= 80;
			client_AddToChat("Vote on as many sudden death modifiers as you want. Need 50%+ total votes for a modifier to be activated.", SColor(255, 50, 130, 80));
		}

		this.set_u32("vote2endtime", getGameTime() + vote2Length);
		this.Sync("vote2endtime", true);

		Icon icon3("MenuItems.png", 2, 32, 32);
		ClickableButton hidebutton("", Vec2f(screenMidX - 220 * scale, screenMidY + 8 * scale), Vec2f(48 * scale, 48 * scale), icon3, 0, scale);
		hidebutton.setGlobalText("HIDE VOTING");

		button_array.push_back(hidebutton);

		int hehe = 160;

		//client_AddToChat("Vote on as many sudden death modifiers as you want. Need 50%+ total votes for a modifier to be activated.", SColor(255, 50, 130, 80));

		SuddenDeathEvent@[] @events;
		if (!this.get("sudden_death_events", @events)) return;

		CBitStream paramsd;

		for (int i=1; i < 6; ++i)
		{
			printf("Ssize: " + events.size());
			if (events.size() == 0)    
			{
				warn("tried taking more sudden death events than there is available");
				break;
			}

			int index = XORRandom(events.size());
			print("adding event to vote" + events[index].name);
			paramsd.write_u16(index);

			Icon icon1("MenuItems.png", 18, 32, 32);
			ClickableButton newEvent("", Vec2f(screenMidX - hehe * scale, screenMidY), Vec2f(64 * scale, 64 * scale), events[index].eventicon, i, scale, false);
			newEvent.setGlobalText(events[index].description);
			hehe -= 64;
			button_array.push_back(newEvent);

			if(isServer() && isClient())
			{
				client_AddToChat("Modifier " + i + ": " + events[index].name, SColor(255, 255, 70, 128));
			}

			event_votes.push_back(events[index]);
			events.removeAt(index); 
		}

		getRules().SendCommand(getRules().getCommandID("sync vote 2"), paramsd);

		this.set("sudden_death_events", @events);
		this.set("sudden_death_events_vote", @event_votes);
	}
	else if(cmd == this.getCommandID("sync vote 2") && isClient() && !isServer())
	{
		for(int i=1; i < 12; ++i)
		{
			this.set_u16("votes for id " + i, 0);
		}

		event_votes.clear();

		float scale = getScreenWidth() >= 2560 ? 2.0f : 1.0f;

		button_array.clear();
		show = false;
		show2 = true;
		hidec = false;
		screenMidX -= 80;

		this.set_u32("vote2endtime", getGameTime() + vote2Length);
		this.Sync("vote2endtime", true);

		Icon icon3("MenuItems.png", 2, 32, 32);
		ClickableButton hidebutton("", Vec2f(screenMidX - 220 * scale, screenMidY + 8 * scale), Vec2f(48 * scale, 48 * scale), icon3, 0, scale);
		hidebutton.setGlobalText("HIDE VOTING");

		button_array.push_back(hidebutton);

		int hehe = 160;

		client_AddToChat("Vote on as many sudden death modifiers as you want. Need 50%+ total votes for a modifier to be activated.", SColor(255, 50, 130, 80));

		SuddenDeathEvent@[]@ events;
		if (!this.get("sudden_death_events", @events)) return;

		for (int i=1; i < 6; ++i)
		{
			printf("Csize: " + events.size());
			if (events.size() == 0)    
			{
				warn("tried taking more sudden death events than there is available");
				break;
			}

			int index = params.read_u16();
			print("adding event to vote" + events[index].name);

			Icon icon1("MenuItems.png", 18, 32, 32);
			ClickableButton newEvent("", Vec2f(screenMidX - hehe * scale, screenMidY), Vec2f(64 * scale, 64 * scale), events[index].eventicon, i, scale, false);
			newEvent.setGlobalText(events[index].description);
			hehe -= 64;
			button_array.push_back(newEvent);

			client_AddToChat("Modifier " + i + ": " + events[index].name, SColor(255, 255, 70, 128));

			event_votes.push_back(events[index]);
			events.removeAt(index); 
		}

		this.set("sudden_death_events", @events);
	}
	else if(cmd == this.getCommandID("end vote 2") && isServer())
	{
		show2 = false;
		hidec = false;
		button_array.clear();

		if(isServer() && isClient())
		{
			screenMidX += 80;
		}

		SuddenDeathEvent@[] @events_active;
		if (!this.get("sudden_death_events_active", @events_active)) return;

		SuddenDeathEvent@[] @events;
		if (!this.get("sudden_death_events", @events)) return;

		bool nothingpassed = true;

		float scale = getScreenWidth() >= 2560 ? 2.0f : 1.0f;

		CBitStream anparams;

		for(int i=0; i < event_votes.size(); ++i)
		{
			int votefor = params.read_u16();
			anparams.write_u16(votefor);

			if(votefor >= (getRules().get_u32("votes to pass")))
			{
				event_votes[i].Activate();
				if(!event_votes[i].onetimeonly)
				{
					events_active.push_back(event_votes[i]);
					ClickableButton listButton("", Vec2f(0, 0), Vec2f(64 * scale, 64 * scale), event_votes[i].eventicon, i, scale, false, false);
					listButton.setGlobalText(event_votes[i].description);
					active_event_buttons.push_back(listButton);
				}
				else
				{
					events.push_back(event_votes[i]);
				}

				if(isClient() && isServer())
				{
					client_AddToChat("ACTIVATING MODIFIER: " + event_votes[i].name + ": " + event_votes[i].description + " (Votes: " + votefor + ", to pass: " + (getRules().get_u32("votes to pass")) + ")", SColor(255, 220, 17, 120));
				}

				if(isServer() && getRules().hasTag("track_stats"))
				{
					string heresmynumber = event_votes[i].name.replace(" ", "-");
					tcpr("ModifierActivate " + heresmynumber + " " + getGameTime());
				}

				nothingpassed = false;
			}
			else
			{
				events.push_back(event_votes[i]);
			}
		}

		event_votes.clear();

		this.set("sudden_death_events", @events);
		this.set("sudden_death_events_active", @events_active);

		if (!this.get("sudden_death_events", @events)) return;

		this.set("sudden_death_events", @events);

		getRules().SendCommand(getRules().getCommandID("sync end vote 2"), anparams);

		if(nothingpassed && events.size() >= 7)
		{
			if(isServer())
			{
				CBitStream params;
				getRules().set_u32("votes to pass", getAllTeamPlayersCount() / 2 + 1);
				getRules().Sync("votes to pass", true);
				getRules().SendCommand(getRules().getCommandID("activate vote 2"), params);
			}
		}
	}
	else if(cmd == this.getCommandID("sync end vote 2") && isClient() && !isServer())
	{
		show2 = false;
		hidec = false;
		button_array.clear();
		screenMidX += 80;

		SuddenDeathEvent@[] @events_active;
		if (!this.get("sudden_death_events_active", @events_active)) return;

		SuddenDeathEvent@[] @events;
		if (!this.get("sudden_death_events", @events)) return;

		bool nothingpassed = true;

		float scale = getScreenWidth() >= 2560 ? 2.0f : 1.0f;
		for(int i=0; i < event_votes.size(); ++i)
		{
			int votefor = params.read_u16();

			if(votefor >= (getRules().get_u32("votes to pass")))
			{
				event_votes[i].Activate();
				if(!event_votes[i].onetimeonly)
				{
					events_active.push_back(event_votes[i]);
					ClickableButton listButton("", Vec2f(0, 0), Vec2f(64 * scale, 64 * scale), event_votes[i].eventicon, i, scale, false, false);
					listButton.setGlobalText(event_votes[i].description);
					active_event_buttons.push_back(listButton);
				}
				else
				{
					events.push_back(event_votes[i]);
				}

				if(isClient())
				{
					client_AddToChat("ACTIVATING MODIFIER: " + event_votes[i].name + ": " + event_votes[i].description + " (Votes: " + votefor + ", to pass: " + (getRules().get_u32("votes to pass")) + ")", SColor(255, 220, 17, 120));
				}

				nothingpassed = false;
			}
			else
			{
				events.push_back(event_votes[i]);
			}
		}

		event_votes.clear();

		this.set("sudden_death_events", @events);
		this.set("sudden_death_events_active", @events_active);

		if (!this.get("sudden_death_events", @events)) return;

		this.set("sudden_death_events", @events);

		if(nothingpassed && events.size() >= 7)
		{
			if(isClient())
			{
				client_AddToChat("Nothing passed; rerolling vote", SColor(255, 50, 130, 80));
			}
		}
	}
	else if(cmd == this.getCommandID("sync all events") && isClient() && !isServer())
	{
		string username = params.read_string();
		if(getLocalPlayer() is null) return;

		if(username != getLocalPlayer().getUsername()) return;
		string eventname = params.read_string();

		SuddenDeathEvent@[] @events;
		if (!this.get("sudden_death_events", @events)) return;

		SuddenDeathEvent@[] @events_active;
		if (!this.get("sudden_death_events_active", @events_active)) return;
		
		float scale = getScreenWidth() >= 2560 ? 2.0f : 1.0f;

		for(int i=0; i<events.size(); ++i)
		{
			if(events[i].name == eventname)
			{
				events_active.push_back(events[i]);

				ClickableButton listButton("", Vec2f(0, 0), Vec2f(64 * scale, 64 * scale), events[i].eventicon, i, scale, false, false);
				listButton.setGlobalText(events[i].description);
				active_event_buttons.push_back(listButton);

				events[i].Activate();

				events.removeAt(i);
			}
		}

		this.set("sudden_death_events", @events);
		this.set("sudden_death_events_active", @events_active);
	}
	else if(cmd == this.getCommandID("button id"))
	{
		u16 i = params.read_u16();
		bool add = params.read_bool();

		if(add)
		{
			this.set_u16("votes for id " + i, this.get_u16("votes for id " + i) + 1);
		}
		else
		{
			this.set_u16("votes for id " + i, this.get_u16("votes for id " + i) - 1);
		}
	}
	else if(cmd == this.getCommandID("button id 0") && isClient())
	{
		bool selected = params.read_bool();
	}
	/*else
	{
		for(int i=1; i < 7; ++i)
		{
			if(cmd == this.getCommandID("button id " + i))
			{
				bool add = params.read_bool();

				if(add)
				{
					this.set_u16("votes for id " + i, this.get_u16("votes for id " + i) + 1);
				}
				else
				{
					this.set_u16("votes for id " + i, this.get_u16("votes for id " + i) - 1);
				}
			}
		}

		if(cmd == this.getCommandID("button id 0") && isClient())
		{
			bool selected = params.read_bool();
		}
	}*/
}

void ShowModifiers()
{
	CPlayer@ player = getLocalPlayer();
	if (player !is null && player.isMyPlayer() && active_event_buttons.size() > 0)
	{
		Menu::CloseAllMenus();
		getHUD().ClearMenus(true);

		float scale = getScreenWidth() >= 2560 ? 2.0f : 1.0f;

		float middlex = getScreenWidth() / 2;
		float middley = getScreenHeight() / 2;

		string description = "List of all active modifiers";

		CRules@ rules = getRules();

		int a=0;
		int b=0;

		for(int i = 0; i < active_event_buttons.size(); ++i)
		{
			if(i < 6)
			{
				a += 2;
			}

			if(i % 6 == 0)
			{
				b += 2;
			}
		}

		CGridMenu@ menu = CreateGridMenu(Vec2f(middlex, middley), null, Vec2f(a, b), description);
		if (menu !is null)
		{
			menu.deleteAfterClick = false;

			//display emote grid
			for(int i = 0; i < active_event_buttons.size(); ++i)
			{
				CBitStream params;
				CGridButton@ button = menu.AddButton(active_event_buttons[i].icon.texture, active_event_buttons[i].icon.frame, Vec2f(active_event_buttons[i].icon.x, active_event_buttons[i].icon.y), active_event_buttons[i].globaltext, rules.getCommandID("do nothing"), Vec2f(2, 2), params);
			}
		}
	}
}
