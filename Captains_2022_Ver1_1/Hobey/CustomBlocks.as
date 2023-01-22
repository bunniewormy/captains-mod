
/**
 *	Template for modders - add custom blocks by
 *		putting this file in your mod with custom
 *		logic for creating tiles in HandleCustomTile.
 *
 * 		Don't forget to check your colours don't overlap!
 *
 *		Note: don't modify this file directly, do it in a mod!
 */

namespace CMap
{
    enum CustomTiles
    {
        //pick tile indices from here - indices > 256 are advised.
        tile_whatever = 300
    };
    
    enum custom_colors {
        team0_expensive_zone_x0 = 0xFF00FDFD,
        team0_expensive_zone_x1 = 0xFF00FEFE,
        team1_expensive_zone_x0 = 0xFFFD0000,
        team1_expensive_zone_x1 = 0xFFFE0000,
    };
};

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
    //change this in your mod
    
    int x = offset % map.tilemapwidth;
    CRules@ rules = getRules();
    
    bool has_set = false;
    
    if      (pixel.color == CMap::team0_expensive_zone_x0) { rules.set_s32("team0_expensive_zone_x0", x); has_set = true; }
    else if (pixel.color == CMap::team0_expensive_zone_x1) { rules.set_s32("team0_expensive_zone_x1", x); has_set = true; }
    else if (pixel.color == CMap::team1_expensive_zone_x0) { rules.set_s32("team1_expensive_zone_x0", x); has_set = true; }
    else if (pixel.color == CMap::team1_expensive_zone_x1) { rules.set_s32("team1_expensive_zone_x1", x); has_set = true; }
}