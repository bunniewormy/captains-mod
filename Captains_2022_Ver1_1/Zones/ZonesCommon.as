#include "Requirements.as"
#include "BuilderCommon.as"

string getPlayersZone(CPlayer@ player)
{
	if (player is null) return "null";

	CRules@ rules = getRules();

	if (rules is null) return "null";

	string team = player.getTeamNum() == 0 ? "_blue" : "_red";

	f32 zone_a_start = rules.get_f32("zone_a_start" + team);
	f32 zone_b_start = rules.get_f32("zone_b_start" + team);
	f32 zone_c_start = rules.get_f32("zone_c_start" + team);

	if(player.getBlob() is null) return "null";

	Vec2f player_pos = player.getBlob().getPosition();

	if (player.getTeamNum() == 0)
	{
		if (player_pos.x > zone_a_start && player_pos.x < zone_b_start)
		{
			return "a";
		}
		if (player_pos.x > zone_b_start && player_pos.x < zone_c_start)
		{
			return "b";
		}
		if (player_pos.x > zone_c_start)
		{
			return "c";
		}
	}
	else 
	{
		if (player_pos.x < zone_a_start && player_pos.x > zone_b_start)
		{
			return "a";
		}
		if (player_pos.x < zone_b_start && player_pos.x > zone_c_start)
		{
			return "b";
		}
		if (player_pos.x < zone_c_start)
		{
			return "c";
		}
	}
	return "null";
}

string getBlobsZone(CBlob@ blob)
{
	if (blob is null) return "null";

	CRules@ rules = getRules();

	if (rules is null) return "null";

	string team = blob.getTeamNum() == 0 ? "_blue" : "_red";

	f32 zone_a_start = rules.get_f32("zone_a_start" + team);
	f32 zone_b_start = rules.get_f32("zone_b_start" + team);
	f32 zone_c_start = rules.get_f32("zone_c_start" + team);

	Vec2f player_pos = blob.getPosition();

	if (blob.getTeamNum() == 0)
	{
		if (player_pos.x > zone_a_start && player_pos.x < zone_b_start)
		{
			return "a";
		}
		if (player_pos.x > zone_b_start && player_pos.x < zone_c_start)
		{
			return "b";
		}
		if (player_pos.x > zone_c_start)
		{
			return "c";
		}
	}
	else 
	{
		if (player_pos.x < zone_a_start && player_pos.x > zone_b_start)
		{
			return "a";
		}
		if (player_pos.x < zone_b_start && player_pos.x > zone_c_start)
		{
			return "b";
		}
		if (player_pos.x < zone_c_start)
		{
			return "c";
		}
	}
	return "null";
}


string getPlacementZone (CBlob@ builder, bool use_position_instead_of_cursor) 
{
    CRules@ rules = getRules();
    
    Vec2f pos = builder.getPosition();
    
    BlockCursor @bc;
    builder.get("blockCursor", @bc);
    if (bc !is null)
    {
        if (!use_position_instead_of_cursor) 
        {
            pos = bc.tileAimPos;
        }
    } 
    else 
    {
        if (!use_position_instead_of_cursor) 
        {
            warn("getPlacementZone: bc is null, and we are meant to use bc.tileAimPos");
            return "null";
        }
    }

    CPlayer@ player = builder.getPlayer();
    if(player is null) return "null";

    string team = player.getTeamNum() == 0 ? "_blue" : "_red";

	f32 zone_a_start = rules.get_f32("zone_a_start" + team);
	f32 zone_b_start = rules.get_f32("zone_b_start" + team);
	f32 zone_c_start = rules.get_f32("zone_c_start" + team);

	string cockstring = "null";

	if (player.getTeamNum() == 0)
	{
		if (pos.x >= zone_a_start && pos.x < zone_b_start)
		{
			cockstring = "a";
		}
		if (pos.x >= zone_b_start && pos.x < zone_c_start)
		{
			cockstring = "b";
		}
		if (pos.x >= zone_c_start)
		{
			cockstring = "c";
		}
	}
	else 
	{
		if (pos.x <= zone_a_start && pos.x > zone_b_start)
		{
			cockstring = "a";
		}
		if (pos.x <= zone_b_start && pos.x > zone_c_start)
		{
			cockstring = "b";
		}
		if (pos.x <= zone_c_start)
		{
			cockstring = "c";
		}
	}

    return cockstring;
}

void getZoneRequirements(CBlob@ this, CBitStream &inout default_requirements, bool use_position_instead_of_cursor, CBitStream &out result, string block="irrelevant") 
{
    CRules@ rules = getRules();
    
    CBitStream requirements;
    string requiredType, requiredName, requiredFriendlyName;
    u16 quantity = 0;
    
    default_requirements.ResetBitIndex();
    ReadRequirement(default_requirements,     requiredType, requiredName, requiredFriendlyName, quantity);
    
    if (getPlacementZone(this, use_position_instead_of_cursor) == "a") 
    {
        s32 cost_modifier = 150;
        if (rules.getCurrentState() == WARMUP || rules.getCurrentState() == INTERMISSION) cost_modifier = 100;
        quantity = float(quantity) * float(cost_modifier) * .01f;
        // quantity *= 2;
        // quantity += quantity / 2; // NOTE(hobey): quantity *= 1.5
    }
    else if (getPlacementZone(this, use_position_instead_of_cursor) == "b") 
    {
        s32 cost_modifier = 100;
        quantity = float(quantity) * float(cost_modifier) * .01f;

        if(block=="stone_block" || block=="stone_door" || block=="back_stone_block") quantity = 9999;
        // quantity *= 2;
        // quantity += quantity / 2; // NOTE(hobey): quantity *= 1.5
    }
    else if (getPlacementZone(this, use_position_instead_of_cursor) == "c") 
    {
        s32 cost_modifier = 80;
        quantity = float(quantity) * float(cost_modifier) * .01f;
        // quantity *= 2;
        // quantity += quantity / 2; // NOTE(hobey): quantity *= 1.5
    }
    AddRequirement(requirements, requiredType, requiredName, requiredFriendlyName, quantity);
    
    result = requirements;
}
