#include "pathway.as";

string path_string = getCaptainsPath();
string commandsoundslocation = path_string + "CommandSounds/";

class VoicelineInfo
{
	string m_name;
	string m_sound;
	u32 m_cooldown;

	VoicelineInfo(string name, string sound, u32 cooldown)
	{
		m_name = name;
		m_sound = sound;
		m_cooldown = cooldown;
	}

	void Play(CPlayer@ player, bool random=false, u8 maxrandomnum = 0)
	{
		u32 time_since_last_sound_use = getGameTime() - getRules().get_u32(player.getUsername() + "lastsoundplayedtime");
		u32 soundcooldown = getRules().get_u32(player.getUsername() + "soundcooldown");

		if(time_since_last_sound_use <= soundcooldown) return;

		getRules().set_u32(player.getUsername() + "lastsoundplayedtime", getGameTime());
		getRules().set_u32(player.getUsername() + "soundcooldown", m_cooldown);

		CBlob@ blob = player.getBlob();
		if (blob is null) return;

		CPlayer@ localplayer = getLocalPlayer();
		if(localplayer is null) return;

		bool localplayer_is_deaf = getRules().get_bool(localplayer.getUsername() + "is_deaf");
		if(localplayer_is_deaf) return;

		bool muted_voicelines = getRules().get_bool(localplayer.getUsername() + " muted voicelines");
		if(muted_voicelines) return;

		Vec2f pos = blob.getPosition();

		if(m_sound == "tuturu")
		{
			random = true;
			maxrandomnum = 9;
		}	
		if(m_sound == "amogus")
		{
			random = true;
			maxrandomnum = 2;
		}


		if(!random)
		{
			Sound::Play(commandsoundslocation + m_sound + ".ogg", pos);
		}
		else
		{
			Sound::Play(commandsoundslocation + m_sound + (XORRandom(maxrandomnum) + 1) + ".ogg", pos);
		}
	}
}

ConfigFile@ openVoicelineConfig()
{
	ConfigFile cfg = ConfigFile();
	if (!cfg.loadFile("../Cache/VoiceBindings2.cfg"))
	{
		cfg.add_u32("i1", 0);
		cfg.add_u32("i2", 1);
		cfg.add_u32("i3", 2);
		cfg.add_u32("i4", 3);
		cfg.add_u32("i5", 4);
		cfg.add_u32("i6", 5);
		cfg.add_u32("i7", 6);
		cfg.add_u32("i8", 7);
		cfg.add_bool("enable key hotkeys", false);
		cfg.add_bool("disable emotes", false);
		cfg.add_bool("emote menu overload", false);
		cfg.add_bool("taunt menu overload", false);
		cfg.add_bool("mute voicelines", false);
		cfg.saveFile("VoiceBindings2.cfg");
	}

	return cfg;
}

string[] vnames =
{
	"Gives me conniptions",
	"Tuturu!",
	"Poggers!",
	"Not poggers!",
	"SEE YA CHUMP",
	"You want forgiveness?\nGet religion",
	"My back... h.. my back!",
	"I'm gonna put some dirt in your eye",
	"I missed the part where that's my problem",
	"You should've thought of that earlier", // 10
	"Pizza time!",
	"Aim issue",
	"Sussy baka",
	"Peanut brain",
	"1v1 me",
	"ez 1v1",
	"Junko are you trolling\nor are you really this shit",
	"Sus",
	"Amogus",
	"I'm a god",
	"They having mats for tunel",
	"It cannot be stoped!",
	"It's morbin time",
	"<asthma attack>"
};

string[] vsounds =
{
	"conniptions",
	"tuturu",
	"poggers",
	"notpoggers2",
	"tobey_chump",
	"tobey_forgiveness",
	"tobey_back",
	"tobey_dirt",
	"tobey_missed",
	"tobey_thought", // 10
	"tobey_pizza",
	"aim_issue",
	"sussy_baka",
	"peanut_brain",
	"1v1me",
	"ez1v1",
	"junkotroll",
	"sus",
	"amogus",
	"imagod",
	"matsfortunnel",
	"cannotbestopped",
	"morbin",
	"asthma"
};

u32[] cooldowns =
{
	45,
	45,
	45,
	45,
	45,
	45,
	150,
	75,
	45,
	60, // 10
	60,
	30,
	30,
	30,
	30,
	30,
	60,
	30,
	30,
	30,
	30,
	30,
	30,
	45
};

void arrayFill(VoicelineInfo@[] @vlist)
{
	vlist.clear();
	for (int i = 0; i < vnames.size(); ++i)
	{
		vlist.push_back(VoicelineInfo(vnames[i], vsounds[i], cooldowns[i]));
	}
}

