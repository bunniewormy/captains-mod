#define CLIENT_ONLY

void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
	Menu::addContextItem(menu, "Voiceline Customization", "VoicelineGUI.as", "void ShowVoicelines()");
}
