#include "Hitters.as";

const u32 ticks_to_die = 20 * getTicksASecond();

void onTick(CRules@ this)
{
	if (!getNet().isServer())
		return;

	for (u32 i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);

		if (p !is null)
		{
			CBlob@ b = p.getBlob();
			if (b !is null)
			{
				if (this.get_bool(p.getUsername() + "_lock_" + b.getName()))
				{
					if (b.getTickSinceCreated() > ticks_to_die)
					{
						b.server_Hit(b, b.getPosition(), Vec2f(0, -1), 300.0f, Hitters::suicide);
						b.server_Die();
					}
				}
			}
		}
	}
}

// render gui for the player
void onRender(CRules@ this)
{
	if (g_videorecording)
		return;

	CPlayer@ p = getLocalPlayer();
	if (p is null || !p.isMyPlayer()) { return; }

	CBlob@ b = p.getBlob();
	if (b !is null)
	{
		if (this.get_bool(p.getUsername() + "_lock_" + b.getName()))
		{
			u32 secs = (ticks_to_die - b.getTickSinceCreated()) / getTicksASecond();

			GUI::DrawTextCentered(getTranslatedString("You're locked out of playing {CLASS}. You will get killed in {TIME} seconds.")
							.replace("{CLASS}", b.getName())
							.replace("{TIME}", "" + secs),
			              Vec2f(getScreenWidth() / 2, getScreenHeight() / 2 - 80.0f + Maths::Sin(getGameTime() / 3.0f) * 5.0f),
			              SColor(255, 255, 113, 55));
		}
	}
}
