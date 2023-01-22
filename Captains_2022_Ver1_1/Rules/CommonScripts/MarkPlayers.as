
// shows indicators above clanmates and players of interest

MarkInfo[] marked;
bool pressed = false;

class CoinButton
{
	u16 amount;
	string player_username;

	bool hovered;

	CoinButton(u16 a, string b)
	{
		amount = a;
		player_username = b;
		hovered = false;
	}

	bool isHovered(Vec2f mousepos, Vec2f origin, Vec2f size)
	{
		Vec2f tl = origin;
		Vec2f br = origin + size;

		return (mousepos.x > tl.x && mousepos.y > tl.y &&
		        mousepos.x < br.x && mousepos.y < br.y);
	}

	void RenderGUI(Vec2f origin, Vec2f size)
	{
		int frame;
		SColor color;

		color = SColor(255, 200, 200, 200);

		if (hovered)
		{
			f32 tint_factor = 0.20;
			color = color.getInterpolated(color_white, tint_factor);
		}

		GUI::DrawPane(origin, origin+size, color);
		GUI::DrawTextCentered("Give\n" + amount + "\ncoins", origin + size / 2, color_white);
	}

	void Update(CControls@ controls, Vec2f origin, Vec2f size)
	{
		if (controls is null) return;

		Vec2f mousepos = controls.getMouseScreenPos();
		const bool mousePressed = controls.isKeyPressed(KEY_LBUTTON);
		const bool mouseJustReleased = controls.isKeyJustReleased(KEY_LBUTTON);

		hovered = this.isHovered(mousepos, origin, size);

		if (hovered && mouseJustReleased)
		{
			Sound::Play("buttonclick.ogg");

			bool selected = true;

			if (getLocalPlayer() !is null)
			{
				CBitStream params;
				params.write_string(getLocalPlayer().getUsername());
				params.write_string(player_username);
				params.write_u16(amount);

				getRules().SendCommand(getRules().getCommandID("donate coins"), params);
			}
		}
	}
}

class MarkInfo
{
	string player_username;
	bool clanMate;
	bool active;

	CoinButton@[] buttons;

	MarkInfo() {};
	MarkInfo(CPlayer@ _player)
	{
		player_username = _player.getUsername();
		active = true;
		buttons.push_back(CoinButton(10, player_username));
		buttons.push_back(CoinButton(50, player_username));
	};

	CPlayer@ player() 
	{
		return getPlayerByUsername(player_username); 
	}
};

void onReload(CRules@ this)
{
	onRestart(this);
}
void onRestart(CRules@ this)
{
	if (!isClient()) return;

	marked.clear();

		for (int player_step = 0; player_step < getPlayersCount(); ++player_step)
		{
			CPlayer@ p = getPlayer(player_step);

			if (p !is null)
			{
				if (p.getTeamNum() == getLocalPlayer().getTeamNum() && !p.isMyPlayer())
				{
					MarkInfo@ info = getMarkInfo(p);
					if (info is null)
					{ 
						marked.push_back(MarkInfo(p));
					}
				}
			}
		}

	updateMarked();
}

void onInit(CRules@ this)
{
	this.addCommandID("donate coins");

	if (!isClient()) return;
	updateMarked();
}

void onTick(CRules@ this)
{
	if (!isClient()) return;
	if (getControls().ActionKeyPressed(AK_MENU) && !pressed)
		markPlayer();

	if (getLocalPlayer() is null) return;
	
	pressed = getControls().ActionKeyPressed(AK_MENU);

	bool shift_pressed = getControls().isKeyPressed(KEY_LSHIFT);

	bool shift_just_pressed = getControls().isKeyJustPressed(KEY_LSHIFT);

	if (shift_just_pressed)
	{
		onRestart(this);
	}

	Vec2f upright(getDriver().getScreenWidth()-200, 220);
	Vec2f downleft(getDriver().getScreenWidth(), 320);

	if (!shift_pressed) return;

	for (int i = 0; i<marked.length();i++)
	{
		CMap@ map = getMap();

		if (map is null) return;
		if (marked is null) return;
		if (marked[i].player() is null) continue;

		CBlob@ blob = marked[i].player().getBlob();

		if (marked[i].active)
		{
			CBlob@ blob = marked[i].player().getBlob();
			/*if (blob !is null)
			{
				if (getLocalPlayer().getBlob() !is null && marked[i].player().getBlob() !is null && getLocalPlayer().getBlob().getControls() !is null)
				{
					if (getLocalPlayer().getBlob().getDistanceTo(marked[i].player().getBlob()) < 96.0f && getControls().isKeyPressed(KEY_LSHIFT) && marked[i].player().getCoins() < 600)
					{
						if (marked[i].buttons[0] !is null && getLocalPlayer().getCoins() >= 10) marked[i].buttons[0].Update(getControls(), upright - Vec2f(64, 0), Vec2f(48, 48));
						if (marked[i].buttons[1] !is null && getLocalPlayer().getCoins() >= 50) marked[i].buttons[1].Update(getControls(), upright - Vec2f(64, -48), Vec2f(48, 48));
					}
				}
			}*/
			upright += Vec2f(0,120);
			downleft += Vec2f(0,120);
		}
	}
}

void onRender(CRules@ this)
{
	if (!isClient()) return;

	if (g_videorecording)
		return;

	if ((getGameTime() % 30) == 0)
	{
		updateMarked();
	}

	Vec2f upright(getDriver().getScreenWidth()-200, 220);
	Vec2f downleft(getDriver().getScreenWidth(), 320);

	bool shift_pressed = getControls().isKeyPressed(KEY_LSHIFT);

	//GUI::DrawText("Hold SHIFT \nto enable coin donating\nto teammates in range", upright+Vec2f(0, -50), SColor(255,255,255,255));

	if (!shift_pressed) return;

	for (int i = 0; i<marked.length();i++)
	{
		CMap@ map = getMap();

		if (map is null) return;
		if (marked is null) return;
		if (marked[i].player() is null) continue;

		CBlob@ blob = marked[i].player().getBlob();

		if (marked[i].active)
		{
			CBlob@ blob = marked[i].player().getBlob();
			GUI::DrawRectangle(upright,downleft,SColor(128,0,0,0));
			GUI::SetFont("menu");
			if (blob !is null)
			{
				/*if (getLocalPlayer().getBlob() !is null && marked[i].player().getBlob() !is null && getLocalPlayer().getBlob().getControls() !is null)
				{
					if (getLocalPlayer().getBlob().getDistanceTo(marked[i].player().getBlob()) < 96.0f && getControls().isKeyPressed(KEY_LSHIFT) && marked[i].player().getCoins() < 600)
					{
						if (marked[i].buttons[0] !is null && getLocalPlayer().getCoins() >= 10) marked[i].buttons[0].RenderGUI(upright - Vec2f(64, 0), Vec2f(48, 48));
						if (marked[i].buttons[1] !is null && getLocalPlayer().getCoins() >= 50) marked[i].buttons[1].RenderGUI(upright - Vec2f(64, -48), Vec2f(48, 48));
					}
				}*/
				renderHPBar(blob, upright+Vec2f(15,20));
				DrawInventoryOnHUD(blob, upright+Vec2f(15,57));
				GUI::DrawText(marked[i].player().getCharacterName(), upright+Vec2f(15,10), SColor(255,255,255,255));
				DrawCoinsOnHUD(marked[i].player().getCoins(), upright+Vec2f(150,20), 0);
			}
			else
			{
				GUI::DrawText(marked[i].player().getCharacterName()+" (dead)", upright+Vec2f(15,10), SColor(255,255,255,255));
				DrawCoinsOnHUD(marked[i].player().getCoins(), upright+Vec2f(150,20), 0);
			}

			upright += Vec2f(0,120);
			downleft += Vec2f(0,120);
			if (blob is null) continue;
			if (map.getTile(blob.getInterpolatedPosition()).light < 0x20 && blob !is getLocalPlayerBlob())
			{
				blob.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 8, Vec2f(8, 8));
				continue;
			}

			CPlayer @player = marked[i].player();
			if (player is null) continue;
			if (player !is getLocalPlayer())
			{
				int deltaY = -2 + Maths::Sin(getGameTime() / 4.5f) * 3.0f;
				
				Vec2f p = blob.getInterpolatedPosition();
				p += Vec2f(0.0f, -blob.getHeight() * 3.0f);
				p.x -= 8;
				Vec2f pos = getDriver().getScreenPosFromWorldPos(p);
				/*
				int rot = 0;
				if (pos.x < 0) {
	            pos.x = 0;
		        }
		        if (pos.y < 0) {
		            pos.y = 0;
		        }
		        if (pos.x >= getDriver().getScreenWidth()) {
		            pos.x  = getDriver().getScreenWidth();
		        }
		        if (pos.y >= getDriver().getScreenHeight()) {
		            pos.y  = getDriver().getScreenHeight();
		        }
				*/
				pos.y += deltaY;
				GUI::DrawIcon("GUI/PartyIndicator.png", 1, Vec2f(16, 16), pos, getCamera().targetDistance*2.0f);
			}
			blob.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 0, Vec2f(8, 8)); 
			
		}
	}	
	
}

void markPlayer()
{
	if (!isClient()) return;

	CMap@ map = getMap();
	CControls@ controls = getControls();
	CPlayer@ local = getLocalPlayer();

	if (map is null || controls is null || local is null) 
		return;
	
	CBlob@[] targets;
	if (!map.getBlobsInRadius(controls.getMouseWorldPos(), 8.0f, @targets))
		return;

	for (uint i = 0; i < targets.length; i++)
	{
		CBlob@ b = targets[i];
		if (b is null || b.getPlayer() is null)
			continue;

		CPlayer@ p = b.getPlayer();
		MarkInfo@ info = getMarkInfo(p);

		if (p.getTeamNum() != getLocalPlayer().getTeamNum()) return;

		if (info is null)
		{ 
			marked.push_back(MarkInfo(p));
		}
		else
		{
			info.active = !info.active;
			if (!info.active)
			{
				CBlob@ blob = info.player().getBlob();
				if (blob !is null)
				{
					blob.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 8, Vec2f(8, 8));
				}
			}
		}
		break;
	}
}

void onPlayerChangedTeam( CRules@ this, CPlayer@ player, u8 oldteam, u8 newteam )
{
	if (!isClient()) return;

	if (player.isMyPlayer()) 
	{
		marked.clear();
		for (int player_step = 0; player_step < getPlayersCount(); ++player_step)
		{
			CPlayer@ p = getPlayer(player_step);

			if (p !is null)
			{
				if (p.getTeamNum() == newteam && !p.isMyPlayer())
				{
					MarkInfo@ info = getMarkInfo(p);
					if (info is null)
					{ 
						marked.push_back(MarkInfo(p));
					}
				}
			}
		}
	}

	if (!player.isMyPlayer())
	{
		MarkInfo@ info = getMarkInfo(player);
		if (info is null)
		{ 
			marked.push_back(MarkInfo(player));
		}
	}
}

void updateMarked()
{
	if (!isClient()) return;

	CPlayer@ local = getLocalPlayer();

	if (local is null || !local.isMyPlayer())
		return;
	for (int i=0;i<marked.length();i++)
	{
		CPlayer@ player = marked[i].player();
		if (marked[i] is null)
		{
			marked.removeAt(i); //push local player marker
			continue;
		}
		if (local.getTeamNum() == getRules().getSpectatorTeamNum())
		{
			marked[i].active = false; //push local player marker
			continue;
		}
		if (player is null) 
		{
			marked.removeAt(i);
			i -= 1;
			continue;
		}
		if (player.getTeamNum() != local.getTeamNum())
		{
			marked[i].active = false; //push local player marker
			continue;
		}
	}
}

MarkInfo@ getMarkInfo(CPlayer@ player)
{
	string name = player.getUsername();
	for (int i = 0; i<marked.length();i++)
	{
		if (marked[i].player_username == name)
		{
			return marked[i];
		}
	}
	return null;
}

void renderHPBar(CBlob@ blob, Vec2f origin)
{
	string heartFile = "GUI/HeartNBubble.png";
	int segmentWidth = 32;
	int HPs = 0;

	for (f32 step = 0.0f; step < blob.getInitialHealth(); step += 0.5f)
	{
		f32 thisHP = blob.getHealth() - step;
		Vec2f heartoffset = (Vec2f(2, 10) * 2);
		Vec2f heartpos = origin + Vec2f(segmentWidth * HPs, 0) + heartoffset;

		GUI::DrawIcon(heartFile, 0, Vec2f(12, 12), heartpos);

		if (thisHP > 0)
		{
			if (thisHP <= 0.125f)
			{
				GUI::DrawIcon(heartFile, 4, Vec2f(12, 12), heartpos);
			}
			else if (thisHP <= 0.25f)
			{
				GUI::DrawIcon(heartFile, 3, Vec2f(12, 12), heartpos);
			}
			else if (thisHP <= 0.375f)
			{
				GUI::DrawIcon(heartFile, 2, Vec2f(12, 12), heartpos);
			}
			else
			{
				GUI::DrawIcon(heartFile, 1, Vec2f(12, 12), heartpos);
			}
		}

		HPs++;
	}
}

void DrawInventoryOnHUD(CBlob@ this, Vec2f tl)
{
	SColor col;
	CInventory@ inv = this.getInventory();
	string[] drawn;
	for (int i = 0; i < inv.getItemsCount(); i++)
	{
		CBlob@ item = inv.getItem(i);
		const string name = item.getName();
		if (drawn.find(name) == -1)
		{
			const int quantity = this.getBlobCount(name);
			drawn.push_back(name);

			GUI::DrawIcon(item.inventoryIconName, item.inventoryIconFrame, item.inventoryFrameDimension, tl + Vec2f(0 + (drawn.length - 1) * 40, -6), 1.0f);

			f32 ratio = float(quantity) / float(item.maxQuantity);
			col = ratio > 0.4f ? SColor(255, 255, 255, 255) :
			      ratio > 0.2f ? SColor(255, 255, 255, 128) :
			      ratio > 0.1f ? SColor(255, 255, 128, 0) : SColor(255, 255, 0, 0);

			GUI::SetFont("menu");
			Vec2f dimensions(0,0);
			string disp = "" + quantity;
			GUI::GetTextDimensions(disp, dimensions);
			GUI::DrawText(disp, tl + Vec2f(14 + (drawn.length - 1) * 40 - dimensions.x/2 , 24), col);
		}
	}
}

void DrawCoinsOnHUD(const int coins, Vec2f tl, const int slot)
{
	if (coins > 0)
	{
		GUI::DrawIconByName("$COIN$", tl + Vec2f(-20 + slot * 40, 0));
		GUI::SetFont("menu");
		GUI::DrawText("" + coins, tl + Vec2f(8 + slot * 40 , 7), color_white);
	}
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("donate coins") && isServer())
	{
		string donator;
		if (!params.saferead_string(donator)) return;

		string recipient;
		if (!params.saferead_string(recipient)) return;

		u16 amount;
		if (!params.saferead_u16(amount)) return;

		CPlayer@ donator_p = getPlayerByUsername(donator);
		CPlayer@ recipient_p = getPlayerByUsername(recipient);

		if (donator_p !is null && recipient_p !is null)
		{
			if (donator_p.getCoins() >= amount)
			{
				donator_p.server_setCoins(donator_p.getCoins() - amount);
				recipient_p.server_setCoins(recipient_p.getCoins() + amount);
			}
		}
	}
}