
#define SERVER_ONLY

const string custom_amount_prop = "gold building amount";

void onDie(CBlob@ this)
{
	int drop_amount = this.exists(custom_amount_prop) ?
			this.get_s32(custom_amount_prop) :
			50;
	if (drop_amount == 0) return;

	CBlob@ blob = server_CreateBlobNoInit('mat_gold');

	if (blob !is null)
	{
		blob.Tag('custom quantity');
		blob.Init();

		blob.server_SetQuantity(drop_amount);

		CRules@ rules = getRules();
		uint team = this.getTeamNum();

		if (rules.getCurrentState() == WARMUP || rules.getCurrentState() == INTERMISSION)
		{
			CBlob@[] storages;
			{
				if (getBlobsByName( "tent", @storages ))
				{
					for (uint step = 0; step < storages.length; ++step)
					{
						CBlob@ storage = storages[step];
						if (storage.getTeamNum() == this.getTeamNum())
						{
							storage.server_PutInInventory(blob);
							break;
						}
					}
				}
			}
		}
		else 
		{
			CBlob@[] blist;
				
			if (getBlobsByName("tent", blist) && this.getName() == "tunnel")
			{
				for(uint step=0; step<blist.length; ++step)
				{
					if (blist[step].getTeamNum() != team)
					{
						blob.setPosition(blist[step].getPosition());
					}
				}
			}
			else 
			{
				blob.setPosition(this.getPosition());
			}
		}
	}
}
