#include "VoicelineCommon.as";

VoicelineInfo@[] list_of_all;

void onRestart(CRules@ this)
{
	if (isServer() && !isClient()) return;

	if(isClient())
	{
		arrayFill(list_of_all);
	}
}

void onInit(CRules@ this)
{
	this.addCommandID("select current vspot");
	this.addCommandID("replace current vspot");
	this.addCommandID("change bool");
	this.addCommandID("sync mute");

	if (isServer() && !isClient()) return;

	if(isClient())
	{
		arrayFill(list_of_all);

		ConfigFile@ cfg2 = openVoicelineConfig();

		if (getLocalPlayer() is null) return;

	   	bool mute_me = cfg2.read_bool("mute voicelines");

	   	CBitStream params;
	   	params.write_bool(mute_me);
	   	params.write_u16(getLocalPlayer().getNetworkID());
	   	this.SendCommand(this.getCommandID("sync mute"), params);
	}
}

void onTick(CRules@ this)
{
	if (list_of_all.size() == 0)
	{
		arrayFill(list_of_all);
	}
}

void ShowVoicelines()
{
	CPlayer@ player = getLocalPlayer();
	if (player !is null && player.isMyPlayer())
	{
		ShowVoicelines(player);
	}
}

void ShowVoicelines(CPlayer@ player)
{
	if (player !is null && player.isMyPlayer() && list_of_all.size() > 0)
	{
		getRules().set_u16("current vspot", 100);
		Menu::CloseAllMenus();
		getHUD().ClearMenus(true);

		float scale = getScreenWidth() >= 2560 ? 2.0f : 1.0f;

		float middlex = getScreenWidth() / 2;
		float middley = getScreenHeight() / 2;

		string description = "List of all voice lines";

		CRules@ rules = getRules();

		int a=16;
		int b=20;

		CGridMenu@ menu = CreateGridMenu(Vec2f(middlex, middley), null, Vec2f(a, b), description);
		if (menu !is null)
		{
			menu.deleteAfterClick = false;

			for(int i = 0; i < list_of_all.size(); ++i)
			{
				CBitStream params;
				params.write_u16(i);
				params.write_u16(player.getNetworkID());
				CGridButton@ button = menu.AddTextButton(list_of_all[i].m_name, rules.getCommandID("replace current vspot"), Vec2f(8, 1), params);
			}

			//CGridButton@ button = menu.AddTextButton("None", rules.getCommandID("replace current vspot"), Vec2f(8, 1), paramsd);
		}

		CBitStream paramsd;
		paramsd.write_u16(100);
		paramsd.write_u16(player.getNetworkID());
		CGridButton@ noneyep = menu.AddTextButton("None", rules.getCommandID("replace current vspot"), Vec2f(8, 1), paramsd);

		if (menu.getButtonsCount() % a != 0)
		{
			menu.FillUpRow();
		}

		CGridButton@ separator = menu.AddTextButton("Select a voiceline spot below, then select which voiceline you want to add to it", Vec2f(16, 2));
		separator.clickable = false;
		separator.SetEnabled(false);

		ConfigFile@ cfg = openVoicelineConfig();

		u8[] voiceBinds;

		for(int i = 1; i < 9; ++i)
		{
			voiceBinds.push_back(cfg.read_u8("i" + i));
		}

		for (int i = 0; i < voiceBinds.size(); i++)
		{
			CBitStream params;
			params.write_u16((i + 1));
			params.write_u16(player.getNetworkID());
			if(voiceBinds[i] > list_of_all.size())
			{
				CGridButton@ button = menu.AddTextButton((i + 1) + ": " + "None", rules.getCommandID("select current vspot"), Vec2f(4, 1), params);
				button.selectOneOnClick = true;
			}
			else
			{
				CGridButton@ button = menu.AddTextButton((i + 1) + ": " + list_of_all[voiceBinds[i]].m_sound, rules.getCommandID("select current vspot"), Vec2f(4, 1), params);
				button.selectOneOnClick = true;
			}
		}

		bool use_with_emote_keys = cfg.read_bool("enable key hotkeys");
		CGridButton@ separator2 = menu.AddTextButton("Use emote hotkeys for voicelines: " + (use_with_emote_keys == true ? "True" : "False"), Vec2f(6, 1));
		separator2.clickable = false;
		separator2.SetEnabled(false);
		CBitStream params;
		params.write_u16(0);
		params.write_u16(player.getNetworkID());
		CGridButton@ change0 = menu.AddTextButton("change", rules.getCommandID("change bool"), Vec2f(2, 1), params);

		bool disable_emotes = cfg.read_bool("disable emotes");
		CGridButton@ separator3 = menu.AddTextButton("Disable emotes on voiceline keys: " + (disable_emotes  == true ? "True" : "False"), Vec2f(6, 1));
		separator3.clickable = false;
		separator3.SetEnabled(false);
		CBitStream params2;
		params2.write_u16(1);
		params2.write_u16(player.getNetworkID());
		CGridButton@ change1 = menu.AddTextButton("change", rules.getCommandID("change bool"), Vec2f(2, 1), params2);

		bool emote_menu_overload = cfg.read_bool("emote menu overload");
		CGridButton@ separator4 = menu.AddTextButton("Make emote wheel show\n voicelines instead: " + (emote_menu_overload == true ? "True" : "False"), Vec2f(6, 1));
		separator4.clickable = false;
		separator4.SetEnabled(false);
		CBitStream params3;
		params3.write_u16(2);
		params3.write_u16(player.getNetworkID());
		CGridButton@ change2 = menu.AddTextButton("change", rules.getCommandID("change bool"), Vec2f(2, 1), params3);

		bool taunt_menu_overload = cfg.read_bool("taunt menu overload");
		CGridButton@ separator5 = menu.AddTextButton("Make taunt menu show\n voicelines instead: " + (taunt_menu_overload  == true ? "True" : "False"), Vec2f(6, 1));
		separator5.clickable = false;
		separator5.SetEnabled(false);
		CBitStream params4;
		params4.write_u16(3);
		params4.write_u16(player.getNetworkID());
		CGridButton@ change3 = menu.AddTextButton("change", rules.getCommandID("change bool"), Vec2f(2, 1), params4);

		bool mute_voicelines = cfg.read_bool("mute voicelines");
		CGridButton@ separator6 = menu.AddTextButton("Mute voicelines: " + (mute_voicelines  == true ? "True" : "False"), Vec2f(6, 1));
		separator6.clickable = false;
		separator6.SetEnabled(false);
		CBitStream params5;
		params5.write_u16(4);
		params5.write_u16(player.getNetworkID());
		CGridButton@ change4 = menu.AddTextButton("change", rules.getCommandID("change bool"), Vec2f(2, 1), params5);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("replace current vspot"))
	{
		u16 index = params.read_u16();
		CPlayer@ player = getPlayerByNetworkId(params.read_u16());

		if(!player.isMyPlayer()) return;

		//if (getRules().get_u16("current vspot") != 100)
		{
			ConfigFile@ cfg = openVoicelineConfig();
			cfg.add_u16("i" + getRules().get_u16("current vspot"), index);
			cfg.saveFile("VoiceBindings2.cfg");

			if(player.getBlob() !is null)
			{
				player.getBlob().Tag("reload emotes");
			}

			ShowVoicelines(player);
		}
	}
	if (cmd == this.getCommandID("select current vspot"))
	{
		u16 index = params.read_u16();
		CPlayer@ player = getPlayerByNetworkId(params.read_u16());

		if(!player.isMyPlayer()) return;

		getRules().set_u16("current vspot", index);
	}
	if (cmd == this.getCommandID("change bool"))
	{
		u16 index = params.read_u16();
		CPlayer@ player = getPlayerByNetworkId(params.read_u16());

		if(!player.isMyPlayer()) return;

		{
			ConfigFile@ cfg = openVoicelineConfig();
			if(index == 0)
			{
				if(cfg.read_bool("enable key hotkeys") == false)
				{
					cfg.add_bool("enable key hotkeys", true);
				}
				else
				{
					cfg.add_bool("enable key hotkeys", false);
				}
				cfg.saveFile("VoiceBindings2.cfg");

				ShowVoicelines(player);

				if(player.getBlob() !is null)
				{
					player.getBlob().Tag("reload emotes");
				}
			}
			if(index == 1)
			{
				if(cfg.read_bool("disable emotes") == false)
				{
					cfg.add_bool("disable emotes", true);
				}
				else
				{
					cfg.add_bool("disable emotes", false);
				}
				cfg.saveFile("VoiceBindings2.cfg");

				ShowVoicelines(player);

				if(player.getBlob() !is null)
				{
					player.getBlob().Tag("reload emotes");
				}
			}
			if(index == 2)
			{
				if(cfg.read_bool("emote menu overload") == false)
				{
					cfg.add_bool("emote menu overload", true);
				}
				else
				{
					cfg.add_bool("emote menu overload", false);
				}
				cfg.saveFile("VoiceBindings2.cfg");

				ShowVoicelines(player);

				if(player.getBlob() !is null)
				{
					player.getBlob().Tag("reload emote menu");
				}
			}
			if(index == 3)
			{
				if(cfg.read_bool("taunt menu overload") == false)
				{
					cfg.add_bool("taunt menu overload", true);
				}
				else
				{
					cfg.add_bool("taunt menu overload", false);
				}
				cfg.saveFile("VoiceBindings2.cfg");

				ShowVoicelines(player);

				if(player.getBlob() !is null)
				{
					player.getBlob().Tag("reload taunts");
				}
			}
			if(index == 4)
			{
				if(cfg.read_bool("mute voicelines") == false)
				{
					CBitStream paramsd;
				   	paramsd.write_bool(true);
				   	paramsd.write_u16(getLocalPlayer().getNetworkID());
				   	this.SendCommand(this.getCommandID("sync mute"), paramsd);
					cfg.add_bool("mute voicelines", true);
				}
				else
				{
					CBitStream paramsd;
				   	paramsd.write_bool(false);
				   	paramsd.write_u16(getLocalPlayer().getNetworkID());
				   	this.SendCommand(this.getCommandID("sync mute"), paramsd);
					cfg.add_bool("mute voicelines", false);
				}
				cfg.saveFile("VoiceBindings2.cfg");

				ShowVoicelines(player);
			}
		}
	}
	if (cmd == this.getCommandID("sync mute") && isServer() )
	{
		bool mute = params.read_bool();
		CPlayer@ player = getPlayerByNetworkId(params.read_u16());

		getRules().set_bool(player.getUsername() + " muted voicelines", mute);
		getRules().Sync(player.getUsername() + " muted voicelines", true);
	}

}