
#include "Hitters.as";

/*
void onInit(CBlob@ this)
{
    this.Tag("ignore_saw");
    this.getCurrentScript().runFlags |= Script::remove_after_this;
}
*/

void onInit(CBlob@ this) {
    this.set_f32("keg_time", 150.0f);
}

void onDie(CBlob@ this)
{
    if (this.hasTag("exploding"))
    {
        if (getNet().isServer()) {
            
            CMap@ map = getMap();
            
            Vec2f pos = this.getPosition();
            int x = int(pos.x/8.f);
            int y = int(pos.y/8.f);
            
            for (int direction = 0; direction < 4; direction++) {
                for (int outward = 0; outward < 5; outward++) {
                    int extra_width = 0;
                    if (outward == 3) extra_width = 1;
                    if (outward == 2) extra_width = 2;
                    for (int widthward = 0; widthward < 3 + extra_width*2; widthward++) {
                        
                        int xx;
                        int yy;
                        
                        if (direction == 0) {
                            xx = x + outward;
                            yy = y + widthward - (extra_width+1);
                        } else if (direction == 1) {
                            xx = x - outward;
                            yy = y + widthward - (extra_width+1);
                        } else if (direction == 2) {
                            xx = x + widthward - (extra_width+1);
                            yy = y + outward;
                        } else if (direction == 3) {
                            xx = x + widthward - (extra_width+1);
                            yy = y - outward;
                        } else {
                            // TODO(hobey): error? assert(false)?
                            break;
                        }
                        
                        if (xx < 0) continue;
                        if (yy < 0) continue;
                        if (xx >= map.tilemapwidth ) continue;
                        if (yy >= map.tilemapheight) continue;
                        
                        int offset = xx + yy * map.tilemapwidth;
                        Vec2f place = Vec2f(xx*8, yy*8);
                        Tile tile = map.getTile(offset);
                        if ((tile.type == CMap::tile_empty) ||
                            (tile.type == CMap::tile_castle_back) ||
                            (tile.type == CMap::tile_castle_back_moss) ||
                            (tile.type == CMap::tile_wood_back) ||
                            // (tile.type == CMap::tile_grass) ||
                            map.isTileGrass(tile.type) ||
                            (tile.type == CMap::tile_ground_back)) {
                            // map.SetTile(offset, CMap::tile_castle_back);
                            map.server_SetTile(place, CMap::tile_castle_back);
                        }
                    }
                }
            }
        }
        
        // Explode(this, this.get_f32("explosive_radius"), this.get_f32("explosive_damage"));
        // Explode(this, 64.0f, 3.0f);
    }
}
