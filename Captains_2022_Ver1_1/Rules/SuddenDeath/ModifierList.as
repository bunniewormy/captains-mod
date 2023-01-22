#define CLIENT_ONLY

void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
	Menu::addContextItem(menu, "Show Modifiers", "InitialVote.as", "void ShowModifiers()");
}
