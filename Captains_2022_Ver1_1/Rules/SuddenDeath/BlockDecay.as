#define SERVER_ONLY

u32 decay_interval = 30 * getTicksASecond();

void onTick(CMap@ this)
{
	if (getGameTime() % decay_interval == 0)
	{
		CMap@ map = getMap();
		Vec2f[] @player_tiles;
		map.get("player_tiles", @player_tiles);

		Vec2f[] hellothere;

		for(int i=0; i<player_tiles.size(); ++i)
		{
			int chance = XORRandom(5);
			if(chance == 0)
			{
				hellothere.push_back(player_tiles[i]);
			}
		}
		for(int i=0; i<hellothere.size(); ++i)
		{
			map.server_DestroyTile(hellothere[i], 1.0f);
		}
	}
} 

void onSetTile(CMap@ this, u32 index, TileType newtile, TileType oldtile)
{	
	u32 x = index % this.tilemapwidth;
	u32 y = index / this.tilemapwidth;
	Vec2f coords(x * this.tilesize, y * this.tilesize);

	Vec2f[] @player_tiles;
	this.get("player_tiles", @player_tiles);

	u32 tindex = player_tiles.find(coords);

	bool isbuilt = false;

	if (this.isTileWood(newtile) || // wood tile
		newtile == CMap::tile_wood_back || // wood backwall
		newtile == 207 || // wood backwall damaged
		this.isTileCastle(newtile) || // castle block
		newtile == CMap::tile_castle_back || // castle backwall
		newtile == 76 || // castle backwall damaged
		newtile == 77 || // castle backwall damaged
		newtile == 78 || // castle backwall damaged
		newtile == 79 || // castle backwall damaged
		newtile == CMap::tile_castle_back_moss) // castle mossbackwall
	{
		isbuilt = true;
	}

	if (tindex != -1 && player_tiles.size() > 0)
	{
		if(isbuilt)
		{

		}
		else
		{
			player_tiles.removeAt(tindex);
		}
	}
	else
	{
		if(isbuilt)
		{
			player_tiles.push_back(coords);
		}
	}

	this.set("player_tiles", @player_tiles);
}
