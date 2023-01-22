void onInit( CMap@ this )
{
    printf("xd, check ctf.as for midshops");
    /*
        // midshop
        CMap@ map = this;
        Vec2f dimensions = map.getMapDimensions();

        u32 block_width = dimensions.x / 8;
        u32 block_height = dimensions.y / 8;

        printf("hemlo");

        bool hasmidshop = false;

        CBlob@ midshop4 = getBlobByName("midshop4");
        if(midshop4 !is null) hasmidshop = true;

        CBlob@ midshop5 = getBlobByName("midshop5");
        if(midshop5 !is null) hasmidshop = true;

        if(this.hasTag("nomidshops")) hasmidshop = true;

        if (hasmidshop)
        {
            return;
        }

        if (block_width % 2 == 0)
        {
            printf("map is even");
            printf("width: " + block_width);

            u32 ymiddle = block_height / 2;
            u32 xmiddle = block_width / 2;

            u32 distance_top, distance_bottom;

            Vec2f midshop_pos_top, midshop_pos_bottom;

            bool top_exists = false;
            bool bottom_exists = false;

            // we go up
            for(u32 i = ymiddle; i > 0; --i)
            {
                if(!map.isTileSolid(Vec2f(xmiddle * map.tilesize, i * map.tilesize)))
                {
                    //printf("Sky at: " + xmiddle + ", " + i);

                    // we go down
                    for(u32 v = i; v < block_height; ++v)
                    {
                        if(map.isTileSolid(Vec2f(xmiddle * map.tilesize, v * map.tilesize)))
                        {
                            //printf("Nearest solid block at:" + xmiddle + ", " + v);

                            midshop_pos_bottom = Vec2f(xmiddle * map.tilesize, (v - 2.5) * map.tilesize);

                            distance_bottom = (v - 3) - ymiddle;

                            bottom_exists = true;

                            //printf("Distance from mid when going bottom: " + distance_bottom);

                            break;
                        }
                    }
                    // we go top
                    for(u32 v = i; v > 0; --v)
                    {
                        if(map.isTileSolid(Vec2f(xmiddle * map.tilesize, v * map.tilesize)))
                        {
                            //printf("Nearest solid block at:" + xmiddle + ", " + v);

                            // time to find sky

                            for(u32 h = v; h > 0; --h)
                            {
                                if(!map.isTileSolid(Vec2f(xmiddle * map.tilesize, h * map.tilesize)))
                                {
                                    midshop_pos_top = Vec2f(xmiddle * map.tilesize, (h - 1.5) * map.tilesize);

                                    distance_top = ymiddle - (h - 2);

                                    top_exists = true;

                                    //printf("Distance from mid when going top: " + distance_top);
                                    break;
                                }
                            }
                            break;
                        }
                    }
                    break;
                }
                else
                {
                    //printf("No sky at:" + xmiddle + ", " + i);
                    continue;
                }
            }

            // we go down
            for(u32 i = ymiddle; i < block_height; ++i)
            {
                if(!map.isTileSolid(Vec2f(xmiddle * map.tilesize, i * map.tilesize)))
                {
                   // printf("Sky at: " + xmiddle + ", " + i);
                    //printf("Searching for closest solid block below");

                    // we go down
                    for(u32 v = i; v < block_height; ++v)
                    {
                        if(map.isTileSolid(Vec2f(xmiddle * map.tilesize, v * map.tilesize)))
                        {
                            //printf("Nearest solid block at:" + xmiddle + ", " + v);

                            midshop_pos_bottom = Vec2f(xmiddle * map.tilesize, (v - 2.5) * map.tilesize);

                            distance_bottom = (v - 3) - ymiddle;

                            bottom_exists = true;

                            //printf("Distance from mid when going bottom: " + distance_bottom);

                            break;
                        }
                    }
                    // we go top
                    for(u32 v = i; v > 0; --v)
                    {
                        if(map.isTileSolid(Vec2f(xmiddle * map.tilesize, v * map.tilesize)))
                        {
                            //printf("Nearest solid block at:" + xmiddle + ", " + v);

                            // time to find sky

                            for(u32 h = v; h > 0; --h)
                            {
                                if(!map.isTileSolid(Vec2f(xmiddle * map.tilesize, h * map.tilesize)))
                                {
                                    midshop_pos_top = Vec2f(xmiddle * map.tilesize, (h - 1.5) * map.tilesize);

                                    distance_top = ymiddle - (h - 2);

                                    top_exists = true;

                                    //printf("Distance from mid when going top: " + distance_top);
                                    break;
                                }
                            }
                            break;
                        }
                    }
                    break;
                }
                else
                {
                    //printf("No sky at:" + xmiddle + ", " + i);
                    continue;
                }
            }

            //CBlob@ midshop = spawnBlob(map, "midshop4", offset, team);

            //printf("Midshop pos top: " + midshop_pos_top)

            if(top_exists && bottom_exists)
            {
                if(distance_top > distance_bottom)
                {
                    //printf("t1");
                    CBlob@ midshop = server_CreateBlob("midshop4", -1, midshop_pos_bottom + Vec2f(0, 8));
                    midshop.getShape().SetStatic(true);
                }
                else if(distance_top < distance_bottom)
                {
                    //printf("t2");
                    printf("midshop_pos_top: " + midshop_pos_top.x + ", " + midshop_pos_top.y);
                    CBlob@ midshop = server_CreateBlob("midshop4", -1, midshop_pos_top + Vec2f(0, 8));
                    midshop.getShape().SetStatic(true);
                }
                else
                {
                    if(XORRandom(2) == 0)
                    {
                        //printf("t3");
                        CBlob@ midshop = server_CreateBlob("midshop4", -1, midshop_pos_top + Vec2f(0, 8));
                        midshop.getShape().SetStatic(true);
                    }
                    else
                    {
                        //printf("t4");
                        CBlob@ midshop = server_CreateBlob("midshop4", -1, midshop_pos_bottom + Vec2f(0, 8));
                        midshop.getShape().SetStatic(true);
                    }
                }
            }
            else if(top_exists && !bottom_exists)
            {
                //printf("t5");
                CBlob@ midshop = server_CreateBlob("midshop4", -1, midshop_pos_top + Vec2f(0, 8));
                midshop.getShape().SetStatic(true);
            }
            else if(!top_exists && bottom_exists)
            {
                //printf("t6");
                CBlob@ midshop = server_CreateBlob("midshop4", -1, midshop_pos_bottom + Vec2f(0, 8));
                midshop.getShape().SetStatic(true);
            }
            else
            {
                printf("Middle of map has no solid blocks");
            }

        }
        else
        {
            printf("map is odd");
            printf("width: " + block_width);

            u32 ymiddle = block_height / 2;
            u32 xmiddle = (block_width + 1) / 2 - 1;

            u32 distance_top, distance_bottom;

            Vec2f midshop_pos_top, midshop_pos_bottom;

            bool top_exists = false;
            bool bottom_exists = false;

            // we go up
            for(u32 i = ymiddle; i > 0; --i)
            {
                if(!map.isTileSolid(Vec2f(xmiddle * map.tilesize, i * map.tilesize)))
                {
                    //printf("Sky at: " + xmiddle + ", " + i);

                    // we go down
                    for(u32 v = i; v < block_height; ++v)
                    {
                        if(map.isTileSolid(Vec2f(xmiddle * map.tilesize, v * map.tilesize)))
                        {
                            //printf("Nearest solid block at:" + xmiddle + ", " + v);

                            midshop_pos_bottom = Vec2f((xmiddle * map.tilesize) + 0.5 * map.tilesize, (v - 2.5) * map.tilesize);

                            distance_bottom = (v - 3) - ymiddle;

                            bottom_exists = true;

                            //printf("Distance from mid when going bottom: " + distance_bottom);

                            break;
                        }

                    }
                    // we go top
                    for(u32 v = i; v > 0; --v)
                    {
                        if(map.isTileSolid(Vec2f(xmiddle * map.tilesize, v * map.tilesize)))
                        {
                            //printf("Nearest solid block at:" + xmiddle + ", " + v);

                            // time to find sky

                            for(u32 h = v; h > 0; --h)
                            {
                                if(!map.isTileSolid(Vec2f(xmiddle * map.tilesize, h * map.tilesize)))
                                {
                                    midshop_pos_top = Vec2f((xmiddle * map.tilesize) + 0.5 * map.tilesize, (h - 1.5) * map.tilesize);

                                    distance_top = ymiddle - (h - 2);

                                    top_exists = true;

                                    //printf("Distance from mid when going top: " + distance_top);
                                    break;
                                }
                            }
                            break;
                        }
                    }
                    break;
                }
                else
                {
                    //printf("No sky at:" + xmiddle + ", " + i);
                    continue;
                }
            }

            // we go down
            for(u32 i = ymiddle; i < block_height; ++i)
            {
                if(!map.isTileSolid(Vec2f(xmiddle * map.tilesize, i * map.tilesize)))
                {
                   // printf("Sky at: " + xmiddle + ", " + i);
                    //printf("Searching for closest solid block below");

                    // we go down
                    for(u32 v = i; v < block_height; ++v)
                    {
                        if(map.isTileSolid(Vec2f(xmiddle * map.tilesize, v * map.tilesize)))
                        {
                            //printf("Nearest solid block at:" + xmiddle + ", " + v);

                            midshop_pos_bottom = Vec2f((xmiddle * map.tilesize) + 0.5 * map.tilesize, (v - 2.5) * map.tilesize);

                            distance_bottom = (v - 3) - ymiddle;

                            bottom_exists = true;

                            //printf("Distance from mid when going bottom: " + distance_bottom);

                            break;
                        }

                    }
                    // we go top
                    for(u32 v = i; v > 0; --v)
                    {
                        if(map.isTileSolid(Vec2f(xmiddle * map.tilesize, v * map.tilesize)))
                        {
                            //printf("Nearest solid block at:" + xmiddle + ", " + v);

                            // time to find sky

                            for(u32 h = v; h > 0; --h)
                            {
                                if(!map.isTileSolid(Vec2f(xmiddle * map.tilesize, h * map.tilesize)))
                                {
                                    midshop_pos_top = Vec2f((xmiddle * map.tilesize) + 0.5 * map.tilesize, (h - 1.5) * map.tilesize);

                                    distance_top = ymiddle - (h - 2);

                                    top_exists = true;

                                    //printf("Distance from mid when going top: " + distance_top);
                                    break;
                                }
                            }
                            break;
                        }
                    }
                    break;
                }
                else
                {
                    //printf("No sky at:" + xmiddle + ", " + i);
                    continue;
                }
            }

            //CBlob@ midshop = spawnBlob(map, "midshop4", offset, team);

            //printf("Midshop pos top: " + midshop_pos_top)

            if(top_exists && bottom_exists)
            {
                if(distance_top > distance_bottom)
                {
                    printf("t1");
                    CBlob@ midshop = server_CreateBlob("midshop5", -1, midshop_pos_bottom + Vec2f(0, 8));
                    midshop.getShape().SetStatic(true);
                }
                else if(distance_top < distance_bottom)
                {
                    printf("t2");
                    printf("midshop_pos_top: " + midshop_pos_top.x + ", " + midshop_pos_top.y);
                    CBlob@ midshop = server_CreateBlob("midshop5", -1, midshop_pos_top + Vec2f(0, 8));
                    midshop.getShape().SetStatic(true);
                }
                else
                {
                    if(XORRandom(2) == 0)
                    {
                        printf("t3");
                        CBlob@ midshop = server_CreateBlob("midshop5", -1, midshop_pos_top + Vec2f(0, 8));
                        midshop.getShape().SetStatic(true);
                    }
                    else
                    {
                        printf("t4");
                        CBlob@ midshop = server_CreateBlob("midshop5", -1, midshop_pos_bottom + Vec2f(0, 8));
                        midshop.getShape().SetStatic(true);
                    }
                }
            }
            else if(top_exists && !bottom_exists)
            {
                printf("t5");
                CBlob@ midshop = server_CreateBlob("midshop5", -1, midshop_pos_top + Vec2f(0, 8));
                midshop.getShape().SetStatic(true);
            }
            else if(!top_exists && bottom_exists)
            {
                printf("t6");
                CBlob@ midshop = server_CreateBlob("midshop5", -1, midshop_pos_bottom + Vec2f(0, 8));
                midshop.getShape().SetStatic(true);
            }
            else
            {
                printf("Middle of map has no solid blocks");
            }
        }*/
}