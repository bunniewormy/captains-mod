
bool is_in_expensive_zone (CBlob@ builder, bool use_position_instead_of_cursor) {
    CRules@ rules = getRules();
    
    Vec2f pos = builder.getPosition();
    
    
    BlockCursor @bc;
    builder.get("blockCursor", @bc);
    if (bc !is null)
    {
        if (!use_position_instead_of_cursor) {
            pos = bc.tileAimPos;
        }
    } else {
        if (!use_position_instead_of_cursor) {
            warn("is_in_expensive_zone: bc is null, and we are meant to use bc.tileAimPos");
            return false;
        }
    }
    
    s32 expensive_zone_start_time = rules.get_s32("expensive_zone_start_time") * 30;
    int match_time = (getRules().exists("match_time") ? getRules().get_u32("match_time") : 0);
    if (match_time < expensive_zone_start_time) return false;
    
    if (!rules.exists("team"+builder.getTeamNum()+"_expensive_zone_x0")) return false;
    if (!rules.exists("team"+builder.getTeamNum()+"_expensive_zone_x1")) return false;
    int x0 = rules.get_s32("team"+builder.getTeamNum()+"_expensive_zone_x0");
    int x1 = rules.get_s32("team"+builder.getTeamNum()+"_expensive_zone_x1");
    int x = int(pos.x / 8.f);
    /*
    if (getNet().isServer()) {
        // TODO(hobey): removeme
        print("is_in_expensive_zone " + ((x >= x0) && (x <= x1)) + ";  x, x0, x1:"+x+", "+x0+", "+x1+ "   (server: "+builder.getPlayer().getUsername()+")");
    } else {
        print("is_in_expensive_zone " + ((x >= x0) && (x <= x1)) + ";  x, x0, x1:"+x+", "+x0+", "+x1+ "   (local)");
    }
    */
    if(builder.getTeamNum() == 0)
    {
        if ((x >= x0) && (x <= x1)) 
        {
            return true;
        }
    }
    else if(builder.getTeamNum() == 1)
    {
        if ((x >= x1) && (x <= x0)) // idk not my problem 
        {
            return true;
        }
    }
    return false;
}

void get_maybe_expensive_zone_requirements (CBlob@ this, CBitStream &inout default_requirements, bool use_position_instead_of_cursor, CBitStream &out result) {
    CRules@ rules = getRules();
    
    CBitStream requirements;
    string requiredType, requiredName, requiredFriendlyName;
    u16 quantity = 0;
    
    default_requirements.ResetBitIndex();
    ReadRequirement(default_requirements,     requiredType, requiredName, requiredFriendlyName, quantity);
    
    if (is_in_expensive_zone(this, use_position_instead_of_cursor)) {
        
        s32 cost_modifier = 100;
        if (rules.exists("expensive_zone_cost_percentage")) {
            cost_modifier = rules.get_s32("expensive_zone_cost_percentage");
        }
        quantity = float(quantity) * float(cost_modifier) * .01f;
        // quantity *= 2;
        // quantity += quantity / 2; // NOTE(hobey): quantity *= 1.5
    }
    AddRequirement(requirements, requiredType, requiredName, requiredFriendlyName, quantity);
    
    result = requirements;
}
