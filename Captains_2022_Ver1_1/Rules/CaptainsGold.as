#define SERVER_ONLY;

void onTick( CRules@ this)
{
	if(getGameTime() == 2)
	{
		CMap@ map = getMap();
		for(int i=0; i < map.tilemapwidth * map.tilemapheight; ++i)
		{
			Tile cock = map.getTile(i);

			if(map.isTileGold(cock.type))
			{
				map.server_SetTile(map.getTileWorldPosition(i), CMap::tile_ground);
			}
		}
	}
}
