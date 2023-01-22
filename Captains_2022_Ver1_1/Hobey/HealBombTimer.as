// #include "RunnerCommon.as"
#include "BombCommon.as";
#include "Hitters.as";
// #include "Explosion.as";

void onInit(CBlob@ this)
{
    if (!this.exists("bomb_timer"))
    {
        this.set_s32("bomb_timer", getGameTime());
    }
    
    // TODO(hobey): radius
    f32 explRadius = 40.0f;
    if (!this.exists("explosive_radius"))
    {
        this.set_f32("explosive_radius", explRadius);
    }
    if (!this.exists("explosive_damage"))
    {
        this.set_f32("explosive_damage", 3.0f);
    }
    
    BombFuseOn(this, explRadius * 0.5f);
    
    //use the bomb hitter
    if (!this.exists("custom_hitter"))
    {
        this.set_u8("custom_hitter", Hitters::bomb);
    }
    /*
    if (!this.exists("map_damage_radius"))
    {
        this.set_f32("map_damage_radius", 24.0f);
    }
    if (!this.exists("map_damage_ratio"))
    {
        this.set_f32("map_damage_ratio", 0.4f);
    }
    if (!this.exists("map_damage_raycast"))
    {
        this.set_bool("map_damage_raycast", true);
    }
    */
}

void Explode(CBlob@ this)
{
    
    if (this.hasTag("exploding"))
    {
        /*
        if (this.exists("explosive_radius") && this.exists("explosive_damage"))
        {
            Explode(this, this.get_f32("explosive_radius"), this.get_f32("explosive_damage"));
        }
        else //default "bomb" explosion
        {
            Explode(this, 64.0f, 3.0f);
        }
        */
        
        {
            float radius = 40.0f;
            
            //hit blobs
            CBlob@[] blobs;
            getMap().getBlobsInRadius(this.getPosition(), radius, @blobs);
            
            for (uint i = 0; i < blobs.length; i++)
            {
                CBlob@ hit_blob = blobs[i];
                if (hit_blob is this)
                    continue;
                
                if (hit_blob.hasTag("player")) {
                    hit_blob.server_Heal(1.0f);
                    
                    /*
                    RunnerMoveVars@ moveVars;
                    if (hit_blob.get("moveVars", @moveVars)) {
                        moveVars.walljumped = false;
                        moveVars.walljumped_side = Walljump::NONE;
                    }
                    */
                }
            }
            
            
            
            
            
            
            for (int i = 0; i < 75; i++) {
                const string particleName = "HealParticle"+(XORRandom(2)+1)+".png";
                const Vec2f pos = this.getPosition() + getRandomVelocity(0, radius, XORRandom(360));
                
                CParticle@ p = ParticleAnimated(particleName, pos, Vec2f(0,0),  0.0f, 1.0f, 1+XORRandom(5), -0.1f, false);
                if (p !is null)
                {
                    p.diesoncollide = true;
                    p.fastcollision = true;
                    p.lighting = true; // required unless you want it so show up under ground
                }
            }
            
        }
        
        this.Untag("exploding");
    }
    
    BombFuseOff(this);
    this.getCurrentScript().runFlags |= Script::remove_after_this;
    if (this.getHealth() < 2.5f || this.hasTag("player"))
    {
        this.getSprite().Gib();
        this.server_Die();
    }
    else
    {
        this.server_Hit(this, this.getPosition(), Vec2f_zero, this.get_f32("explosive_damage") * 1.5f, 0);
    }
}

void onTick(CBlob@ this)
{
    if (!UpdateBomb(this))
    {
        Explode(this);
    }
}

void onDie(CBlob@ this)
{
    Explode(this);
}

// run the tick so we explode in inventory
void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
    this.doTickScripts = true;
    //this.getSprite().SetEmitSoundPaused( false );
}
