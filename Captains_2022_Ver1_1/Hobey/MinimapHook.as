///Minimap Code
// Almost 100% accurately replicates the legacy minimap drawer
// This is due to it being a port of the legacy code, provided by Geti
/*
void CalculateMinimapColour( CMap@ map, u32 offset, TileType tile, SColor &out col)
{
    int X = offset % map.tilemapwidth;
    int Y = offset/map.tilemapwidth;
    
    Vec2f pos = Vec2f(X, Y);
    
    float ts = map.tilesize;
    Tile ctile = map.getTile(pos * ts);
    
    bool show_gold = getRules().get_bool("show_gold");
    
    ///Colours
    
    // const SColor color_minimap_solid_edge   (0xff844715);
    // const SColor color_minimap_solid        (0xffc4873a);
    
    const SColor color_minimap_ground_edge        (0xff542712);
    const SColor color_minimap_ground             (0xff74270a);
    const SColor color_minimap_bedrock_edge       (0xff549745);
    const SColor color_minimap_bedrock            (0xff448735);
    
    const SColor color_minimap_thickstone_edge   (0xffa4a4a4);
    const SColor color_minimap_thickstone        (0xffa4a4a4);
    const SColor color_minimap_stone_edge        (0xff747775);
    const SColor color_minimap_stone             (0xff747775);
    
    const SColor color_minimap_castle_edge   (0xff848785);
    const SColor color_minimap_castle        (0xff94979a);
    const SColor color_minimap_wood_edge     (0xff844715);
    const SColor color_minimap_wood          (0xffc4873a);
    
    // const SColor color_minimap_back_edge    (0xffc4873a); //yep, same as above
    const SColor color_minimap_back         (0x5ff3ac5c);
    
    // const SColor color_minimap_open         (0x00edcca6);
    // const SColor color_minimap_open         (0xff7dbcf6);
    const SColor color_minimap_open         (0x5ffefefe);
    
    // const SColor color_minimap_gold         (0xffffbd34);
    const SColor color_minimap_gold         (0xffff5d34);
    // const SColor color_minimap_gold_edge    (0xffc56c22);
    // const SColor color_minimap_gold_exposed (0xfff0872c);
    
    const SColor color_minimap_water        (0xff2cafde);
    const SColor color_minimap_fire         (0xffd5543f);
    
    //neighbours
    Tile tile_l = map.getTile(MiniMap::clampInsideMap(pos * ts - Vec2f(ts, 0), map));
    Tile tile_r = map.getTile(MiniMap::clampInsideMap(pos * ts + Vec2f(ts, 0), map));
    Tile tile_u = map.getTile(MiniMap::clampInsideMap(pos * ts - Vec2f(0, ts), map));
    Tile tile_d = map.getTile(MiniMap::clampInsideMap(pos * ts + Vec2f(0, ts), map));
    
    // bool isTileInFire(int xTilespace, int yTilespace)
    // bool isTileSolid(uint16 tile)
    // bool isTileSolid(const Tile&in tile)
    // bool isTileSolid(Vec2f posWorldspace)
    // bool isTileCollapsing(uint offset)
    // bool isTileCollapsing(Vec2f posWorldspace)
    // bool isTileLadder(const Tile&in tile)
    // bool isTileBackground(const Tile&in tile)
    // bool isTileBackgroundNonEmpty(const Tile&in tile)
    // bool isTileGroundBack(uint16 tile)
    // bool isTileGold(uint16 tile)
    // bool isTileGrass(uint16 tile)
    // bool isTileWood(uint16 tile)
    // bool isTileCastle(uint16 tile)
    // bool isTileSand(uint16 tile)
    // bool isTileGroundStuff(uint16 tile)
    // bool isTilePlatform(const Tile&in tile)
    
    bool is_edge = (MiniMap::isForegroundOutlineTile(tile_u, map) ||
                    MiniMap::isForegroundOutlineTile(tile_d, map) ||
                    MiniMap::isForegroundOutlineTile(tile_l, map) ||
                    MiniMap::isForegroundOutlineTile(tile_r, map) );
    is_edge = false;
    
    if (show_gold && map.isTileGold(tile)) {
        //Gold
        col = color_minimap_gold;
        
        //Edge
        // if( MiniMap::isGoldOutlineTile(tile_u, map, true) || MiniMap::isGoldOutlineTile(tile_d, map, true) ||
        // MiniMap::isGoldOutlineTile(tile_l, map, true) || MiniMap::isGoldOutlineTile(tile_r, map, true) )
        // {
        // col = color_minimap_gold_exposed;
        // }
        
    } else if (map.isTileGround(tile)) {
        if (is_edge) {
            col = color_minimap_ground_edge;
        } else {
            col = color_minimap_ground;
        }
        // MiniMap::isGoldOutlineTile(tile_u, map, false) || MiniMap::isGoldOutlineTile(tile_d, map, false) ||
        // MiniMap::isGoldOutlineTile(tile_l, map, false) || MiniMap::isGoldOutlineTile(tile_r, map, false)
        // col = color_minimap_gold_edge;
    } else if (map.isTileThickStone(tile)) {
        if (is_edge) {
            col = color_minimap_thickstone_edge;
        } else {
            col = color_minimap_thickstone;
        }
    } else if (map.isTileStone(tile)) {
        if (is_edge) {
            col = color_minimap_stone_edge;
        } else {
            col = color_minimap_stone;
        }
    } else if (map.isTileBedrock(tile)) {
        if (is_edge) {
            col = color_minimap_bedrock_edge;
        } else {
            col = color_minimap_bedrock;
        }
    } else if (map.isTileWood(tile)) {
        if (is_edge) {
            col = color_minimap_wood_edge;
        } else {
            col = color_minimap_wood;
        }
    } else if (map.isTileCastle(tile)) {
        if (is_edge) {
            col = color_minimap_castle_edge;
        } else {
            col = color_minimap_castle;
        }
        // } else if(map.isTileBackground(ctile) && !map.isTileGrass(tile))
    } else if(map.isTileBackgroundNonEmpty(ctile) && !map.isTileGrass(tile))
    {
        //Background
        col = color_minimap_back;
        
        //Edge
        // if( MiniMap::isBackgroundOutlineTile(tile_u, map) || MiniMap::isBackgroundOutlineTile(tile_d, map) ||
        // MiniMap::isBackgroundOutlineTile(tile_l, map) || MiniMap::isBackgroundOutlineTile(tile_r, map) )
        // {
        // col = color_minimap_back_edge;
        // }
    }
    else
    {
        //Sky
        col = color_minimap_open;
    }
    
    ///Tint the map based on Fire/Water State
    if (map.isInWater( pos * ts ))
    {
        col = col.getInterpolated(color_minimap_water,0.5f);
    }
    else if (map.isInFire( pos * ts ))
    {
        col = col.getInterpolated(color_minimap_fire,0.5f);
    }
}
*/
void CalculateMinimapColour( CMap@ map, u32 offset, TileType tile, SColor &out col)
{
    int X = offset % map.tilemapwidth;
    int Y = offset/map.tilemapwidth;
    
    Vec2f pos = Vec2f(X, Y);
    
    float ts = map.tilesize;
    Tile ctile = map.getTile(pos * ts);
    
    bool show_gold = getRules().get_bool("show_gold");
    
    ///Colours
    
    const SColor color_minimap_open         (0xffA5BDC8);
    const SColor color_minimap_ground       (0xff844715);
    const SColor color_minimap_back         (0xff3B1406);
    const SColor color_minimap_stone             (0xff8B6849);
    const SColor color_minimap_thickstone        (0xff42484B);
    const SColor color_minimap_gold         (0xffFEA53D);
    const SColor color_minimap_bedrock            (0xff2D342D);
    const SColor color_minimap_wood          (0xffC48715);
    const SColor color_minimap_castle        (0xff637160);
    
    const SColor color_minimap_castle_back (0xff313412);
    const SColor color_minimap_wood_back (0xff552A11);
    
    const SColor color_minimap_water        (0xff2cafde);
    const SColor color_minimap_fire         (0xffd5543f);
    
    //neighbours
    Tile tile_l = map.getTile(MiniMap::clampInsideMap(pos * ts - Vec2f(ts, 0), map));
    Tile tile_r = map.getTile(MiniMap::clampInsideMap(pos * ts + Vec2f(ts, 0), map));
    Tile tile_u = map.getTile(MiniMap::clampInsideMap(pos * ts - Vec2f(0, ts), map));
    Tile tile_d = map.getTile(MiniMap::clampInsideMap(pos * ts + Vec2f(0, ts), map));
    
    // bool isTileInFire(int xTilespace, int yTilespace)
    // bool isTileSolid(uint16 tile)
    // bool isTileSolid(const Tile&in tile)
    // bool isTileSolid(Vec2f posWorldspace)
    // bool isTileCollapsing(uint offset)
    // bool isTileCollapsing(Vec2f posWorldspace)
    // bool isTileLadder(const Tile&in tile)
    // bool isTileBackground(const Tile&in tile)
    // bool isTileBackgroundNonEmpty(const Tile&in tile)
    // bool isTileGroundBack(uint16 tile)
    // bool isTileGold(uint16 tile)
    // bool isTileGrass(uint16 tile)
    // bool isTileWood(uint16 tile)
    // bool isTileCastle(uint16 tile)
    // bool isTileSand(uint16 tile)
    // bool isTileGroundStuff(uint16 tile)
    // bool isTilePlatform(const Tile&in tile)
    
    // bool is_edge = (MiniMap::isForegroundOutlineTile(tile_u, map) ||
    // MiniMap::isForegroundOutlineTile(tile_d, map) ||
    // MiniMap::isForegroundOutlineTile(tile_l, map) ||
    // MiniMap::isForegroundOutlineTile(tile_r, map) );
    
    if (show_gold && map.isTileGold(tile)) {
        //Gold
        col = color_minimap_gold;
        
        //Edge
        // if( MiniMap::isGoldOutlineTile(tile_u, map, true) || MiniMap::isGoldOutlineTile(tile_d, map, true) ||
        // MiniMap::isGoldOutlineTile(tile_l, map, true) || MiniMap::isGoldOutlineTile(tile_r, map, true) )
        // {
        // col = color_minimap_gold_exposed;
        // }
        
    } else if (map.isTileGround(tile)) { col = color_minimap_ground;
    } else if (map.isTileThickStone(tile)) { col = color_minimap_thickstone;
    } else if (map.isTileStone(tile)) { col = color_minimap_stone;
    } else if (map.isTileBedrock(tile)) { col = color_minimap_bedrock;
    } else if (map.isTileWood(tile)) { col = color_minimap_wood;
    } else if (map.isTileCastle(tile)) { col = color_minimap_castle;
        // } else if(map.isTileBackground(ctile) && !map.isTileGrass(tile))
    } else if(map.isTileBackgroundNonEmpty(ctile) && !map.isTileGrass(tile)) { col = color_minimap_back;
        if (tile == CMap::tile_castle_back)  {col = color_minimap_castle_back;
        } else if (tile == CMap::tile_wood_back) { col = color_minimap_wood_back;
        } else { col = color_minimap_back; }
    } else { col = color_minimap_open;
    }
    
    ///Tint the map based on Fire/Water State
    if (map.isInWater( pos * ts ))
    {
        col = col.getInterpolated(color_minimap_water,0.5f);
    }
    else if (map.isInFire( pos * ts ))
    {
        col = col.getInterpolated(color_minimap_fire,0.5f);
    }
}

//(avoid conflict with any other functions)
namespace MiniMap
{
    Vec2f clampInsideMap(Vec2f pos, CMap@ map)
    {
        return Vec2f(
            Maths::Clamp(pos.x, 0, (map.tilemapwidth - 0.1f) * map.tilesize),
            Maths::Clamp(pos.y, 0, (map.tilemapheight - 0.1f) * map.tilesize)
            );
    }
    
    bool isForegroundOutlineTile(Tile tile, CMap@ map)
    {
        return !map.isTileSolid(tile);
    }
    
    bool isOpenAirTile(Tile tile, CMap@ map)
    {
        return tile.type == CMap::tile_empty ||
            map.isTileGrass(tile.type);
    }
    
    bool isBackgroundOutlineTile(Tile tile, CMap@ map)
    {
        return isOpenAirTile(tile, map);
    }
    
    bool isGoldOutlineTile(Tile tile, CMap@ map, bool is_gold)
    {
        return is_gold ?
            !map.isTileSolid(tile.type) :
        map.isTileGold(tile.type);
    }
    
    //setup the minimap as required on server or client
    void Initialise()
    {
        CRules@ rules = getRules();
        CMap@ map = getMap();
        
        //add sync script
        //done here to avoid needing to modify gamemode.cfg
        if (!rules.hasScript("MinimapSync.as"))
        {
            rules.AddScript("MinimapSync.as");
        }
        
        //init appropriately
        if (isServer())
        {
            //load values from cfg
            ConfigFile cfg();
            cfg.loadFile("Base/Rules/MinimapSettings.cfg");
            
            map.legacyTileMinimap = cfg.read_bool("legacy_minimap", false);
            bool show_gold = cfg.read_bool("show_gold", true);
            
            //write out values for serialisation
            rules.set_bool("legacy_minimap", map.legacyTileMinimap);
            rules.set_bool("show_gold", show_gold);
        }
        else
        {
            //write defaults for now
            map.legacyTileMinimap = false;
            rules.set_bool("show_gold", true);
        }
    }
}