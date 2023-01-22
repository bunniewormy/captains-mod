#include "EmotesCommon.as"
#include "WheelMenuCommon.as"
#include "VoicelineCommon.as"

#define CLIENT_ONLY

VoicelineInfo@[] all_voicelinesem;

bool emote_overload = false;

void onInit(CRules@ rules)
{
	string filename = "EmoteEntries.cfg";
	string cachefilename = "../Cache/" + filename;
	ConfigFile cfg;

	//attempt to load from cache first
	bool loaded = false;
	if (CFileMatcher(cachefilename).getFirst() == cachefilename && cfg.loadFile(cachefilename))
	{
		loaded = true;
	}
	else if (cfg.loadFile(filename))
	{
		loaded = true;
	}

	if (!loaded)
	{
		return;
	}

	all_voicelinesem.clear();

    ConfigFile@ cfg2 = openVoicelineConfig();
    arrayFill(all_voicelinesem);

   	emote_overload = cfg2.read_bool("emote menu overload");

    WheelMenu@ menut = get_wheel_menu("Voicelines_emotes");
	menut.option_notice = getTranslatedString("Select voiceline");

	for (u32 i = 0; i < all_voicelinesem.size(); i++)
	{
		WheelMenuEntry subtentry(all_voicelinesem[i].m_sound);
		subtentry.visible_name = all_voicelinesem[i].m_name;
		subtentry.id = i;
		menut.entries.push_back(@subtentry);
	}

	WheelMenu@ menu = get_wheel_menu("emotes");
	menu.option_notice = getTranslatedString("Select emote");

	string[] names;
	cfg.readIntoArray_string(names, "emotes");

	if (names.length % 2 != 0)
	{
		error("EmoteEntries.cfg is not in the form of visible_name; token;");
		return;
	}

	for (uint i = 0; i < names.length; i += 2)
	{
		IconWheelMenuEntry entry(names[i+1]);
		entry.visible_name = getTranslatedString(names[i]);
		entry.texture_name = "Emoticons.png";
		entry.frame = Emotes::names.find(names[i+1]);
		entry.frame_size = Vec2f(32.0f, 32.0f);
		entry.scale = 1.0f;
		entry.offset = Vec2f(0.0f, -3.0f);
		menu.entries.push_back(@entry);
	}
}

void onTick(CRules@ rules)
{
	CBlob@ blob = getLocalPlayerBlob();

	if (blob is null)
	{
		set_active_wheel_menu(null);
		return;
	}
	else
	{
		if(blob.hasTag("reload emote menu"))
		{
  			ConfigFile@ cfg2 = openVoicelineConfig();
	   		emote_overload = cfg2.read_bool("emote menu overload");
			blob.Untag("reload emote menu");
		}
	}

	if(emote_overload)
	{
		WheelMenu@ menut = get_wheel_menu("Voicelines_emotes");

		if (blob.isKeyPressed(key_bubbles) && get_active_wheel_menu() is null) //activate taunt menu
		{
			set_active_wheel_menu(@menut);
		}
		else if (blob.isKeyJustReleased(key_bubbles) && get_active_wheel_menu() is menut) //exit taunt menu
		{
			WheelMenuEntry@ selected = menut.get_selected();
			if (selected !is null)
			{
				CPlayer@ player = getLocalPlayer();
				if(player is null) return;

				CBitStream params;
				params.write_u16(selected.id);
				params.write_u16(player.getNetworkID());
				rules.SendCommand(rules.getCommandID("play sound urabubu"), params, true);
			}
			set_active_wheel_menu(null);
		}
		return;
	}

	WheelMenu@ menu = get_wheel_menu("emotes");

	if (blob.isKeyJustPressed(key_bubbles))
	{
		set_active_wheel_menu(@menu);
	}
	else if (blob.isKeyJustReleased(key_bubbles) && get_active_wheel_menu() is menu)
	{
		WheelMenuEntry@ selected = menu.get_selected();
		set_emote(blob, (selected !is null ? Emotes::names.find(selected.name) : Emotes::off));
		set_active_wheel_menu(null);
	}
}


void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("play sound urabubu"))
    {
        u16 index = params.read_u16();
        u16 playerid = params.read_u16();

        CPlayer@ player = getPlayerByNetworkId(playerid);

        if(player !is null)
        {
            all_voicelinesem[index].Play(player);
        }
    }
}
