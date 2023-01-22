void onAddToInventory( CBlob@ this, CBlob@ blob )
{
	if(this !is null && blob !is null)
	{
		if(this.getPlayer() !is null)
		{
			if(blob.getName() == "food" || blob.getName() == "grain" || blob.getName() == "egg" )
			{
				CInventory@ inventory = this.getInventory();
				int hasfood = 0;
				CBlob@ ourburga = null;

				for(int i=0; i < inventory.getItemsCount(); ++i)
				{
					if (inventory.getItem(i) !is null)
					{
						if (inventory.getItem(i).getName() == "food" || inventory.getItem(i).getName() == "grain" || inventory.getItem(i).getName() == "egg")
						{
							hasfood += 1;
							@ourburga = inventory.getItem(i);
						}
					}
				}

				if(hasfood > 1 && ourburga !is null)
				{
					this.server_PutOutInventory(blob);
					if(blob !is null)
					{
						this.server_Pickup(blob);
					}
					this.set_u32("displayburgermsguntil", getGameTime() + 30);
					this.Sync("displayburgermsguntil", true);
					this.getSprite().PlaySound("Entities/Characters/Sounds/NoAmmo.ogg", 0.5);
				}
			}
		}
	}
}

void onRender(CSprite@ this)
{
	if(this is null) return;

	if(this.getBlob() is null) return;

	if(this.getBlob().getPlayer() is null) return;

	if(this.getBlob().get_u32("displayburgermsguntil") > getGameTime() && this.getBlob().isMyPlayer())
	{
		Vec2f drawpos = Vec2f(getScreenWidth() / 2, getScreenHeight() / 2 - 10.0f);
		GUI::DrawTextCentered("Cannot have more than 1 food item in inventory", drawpos, SColor(255, 255, 55, 55));
	}
}