
bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{

	if (player is null) return true;

	CRules@ rules = getRules();

	if(rules is null) return true;

	string username = player.getUsername();

	if (text_in == "!spam")
	{
		u32 spaminterval = 0;
		rules.set_u32("spam_interval", spaminterval);
	}
	else if (text_in == "!nospam") 
	{
		u32 spaminterval = 30;
		rules.set_u32("spam_interval", spaminterval);
	}
	
	string[]@ tokens = text_in.split(" ");
	
	if (tokens[0] == "!nospam")
	{

		int interval = (tokens.length() >= 2) ? parseInt(tokens[1]) : 30;
		if (interval < 0) interval = 30;
		u32 spaminterval = interval;
		rules.set_u32("spam_interval", spaminterval);
	}

	string prevmessage = rules.get_string("lastmessage_" + username);
	u32 lastmessagetime = rules.get_u32("lastmessagetime" + username);

	if (text_in == prevmessage && getGameTime() - lastmessagetime < rules.get_u32("spam_interval"))
	{
		return false;
	}

	/*printf("last message: " + prevmessage);
	printf("last message time: " + lastmessagetime);
	printf("current time: " + getGameTime());*/

	rules.set_string("lastmessage_" + username, text_in);
	rules.set_u32("lastmessagetime" + username, getGameTime());

	return true;
}

//void onNewPlayerJoin(CRules@ this, CPlayer@ player)
void onInit(CRules@ this)
{
	if(getRules() !is null && isServer())
	{
		getRules().set_u32("spam_interval", 30);
	}
}