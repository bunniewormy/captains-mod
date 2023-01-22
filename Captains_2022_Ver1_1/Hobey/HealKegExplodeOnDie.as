
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
        
        {
            float radius = 64.0f;
            
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
            
            if (getNet().isServer()) {
                float magnitude = radius*0.3f;
                for (int i = 0; i < 3; i++) {
                    CBlob@ food = server_CreateBlob("food", this.getTeamNum(), this.getPosition());
                    food.setVelocity(getRandomVelocity(90, magnitude *.2 + XORRandom(magnitude*.5), 10/*XORRandom(90)*/));
                }
                for (int i = 0; i < 5; i++) {
                    CBlob@ food = server_CreateBlob("heart", this.getTeamNum(), this.getPosition());
                    food.setVelocity(getRandomVelocity(90, magnitude *.2 + XORRandom(magnitude*.5), 10/*XORRandom(90)*/));
                }
            }
        }
        
        
        
        // Explode(this, this.get_f32("explosive_radius"), this.get_f32("explosive_damage"));
        // Explode(this, 64.0f, 3.0f);
    }
}
