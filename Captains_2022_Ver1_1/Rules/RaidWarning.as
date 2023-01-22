#include "RulesCore.as";
#include "Logging.as"
#include "pathway.as"

string path_string = getCaptainsPath();
string rwsound = path_string + "Rules/";

bool onServerProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	RulesCore@ core;
	this.get("core", @core);

	if (player is null)
		return true;
	
	string[]@ tokens = text_in.split(" ");
	u8 tlen = tokens.length;

	/*if(tlen > 1)
	{
		if (tokens[0] == "!rw" && tokens[1] == "on" && player.getUsername() == "HomekGod") 
		{
			this.set_bool("rw " + player.getUsername(), true);
			this.Sync("rw " + player.getUsername(), true);
			getNet().server_SendMsg("Alert mode enabled for: " + player.getUsername());
	    }
	    else if (tokens[0] == "!rw" && tokens[1] == "off" && player.getUsername() == "HomekGod") 
		{
			this.set_bool("rw " + player.getUsername(), false);
			this.Sync("rw " + player.getUsername(), true);
			getNet().server_SendMsg("Alert mode disabled for: " + player.getUsername());
	    }
	}*/

	return true;
}

void onRestart(CRules@ this)
{
	this.set_u32("alert time", 0);
	this.set_string("current alert", "");
}

bool onClientProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	RulesCore@ core;
	this.get("core", @core);

	if (player is null || getLocalPlayer() is null)
		return true;

	string[]@ tokens = text_in.split(" ");
	u8 tlen = tokens.length;

	if (tokens[0] == "!a" && player.getTeamNum() == getLocalPlayer().getTeamNum() && player.getUsername() == "HomekGod" && text_in != "!rw on")
	{
		Sound::Play(rwsound + "RaidWarning.ogg");
		string alert = text_in;
		alert = alert.substr(2);
		this.set_string("current alert", alert);
		this.set_u32("alert time", getGameTime());
	}

	return true;
}

string get_font(string file_name, s32 size)
{
    string result = file_name+"_"+size;
    if (!GUI::isFontLoaded(result)) {
        string full_file_name = CFileMatcher(file_name+".ttf").getFirst();
        // TODO(hobey): apparently you cannot load multiple different sizes of a font from the same font file in this api?
        GUI::LoadFont(result, full_file_name, size, true);
    }
    return result;
}

void onRender(CRules@ this)
{
	float screen_size_x = getDriver().getScreenWidth();
    float screen_size_y = getDriver().getScreenHeight();
	float resolution_scale = screen_size_y / 720.f; // NOTE(hobey): scaling relative to 1280x720
	string phrase_font_name              = get_font("GenShinGothic-P-Medium", s32(24.f * resolution_scale));
	GUI::SetFont(phrase_font_name);
	if (getGameTime() - this.get_u32("alert time") < 30 * 5)
	{
		string alert = this.get_string("current alert");

		GUI::DrawTextCentered(alert, Vec2f(getScreenWidth() / 2, getScreenHeight() / 3 - 70.0f),
			        SColor(255, 255, 55, 55));
	}
}