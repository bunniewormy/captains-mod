// uh oh
// hacky solution, will add engine hooks to make this more easier in the future
#define SERVER_ONLY

void onInit(CRules@ this)
{
	this.set_u16("coincap", 600);
	this.Sync("coincap", true);
}
void onRestart(CRules@ this)
{
	this.set_u16("coincap", 600);
	this.Sync("coincap", true);
}
void onTick(CRules@ this)
{
    for(int a = 0; a < getPlayerCount(); a++)
    {
        CPlayer@ p = getPlayer(a);
        if(p is null) continue;
        if(p.getCoins() > this.get_u16("coincap")) p.server_setCoins(this.get_u16("coincap"));
    }
}  