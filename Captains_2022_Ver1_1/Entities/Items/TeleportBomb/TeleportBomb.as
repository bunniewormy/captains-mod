// Bomb logic

#include "Hitters.as";
#include "BombCommon.as";
#include "ShieldCommon.as";

const s32 teleportbomb_fuse = 120;

void onInit(CBlob@ this)
{
	this.set_u16("explosive_parent", 0);
	this.getShape().getConsts().net_threshold_multiplier = 2.0f;
	SetupBomb(this, teleportbomb_fuse, 48.0f, 0.0f, 24.0f, 0.4f, true);
	//
	this.Tag("activated"); // make it lit already and throwable
	
	CShape@ shape = this.getShape();
	this.addCommandID("teleport bomb");
	//shape.SetRotationsAllowed(false);
	//shape.SetGravityScale(0.0);
}

//start ugly bomb logic :)

void set_delay(CBlob@ this, string field, s32 delay)
{
	this.set_s32(field, getGameTime() + delay);
}

//sprite update

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Vec2f vel = blob.getVelocity();

	s32 timer = blob.get_s32("bomb_timer") - getGameTime();

	if (timer < 0)
	{
		return;
	}

	if (timer > 30)
	{
		this.SetAnimation("default");
		this.animation.frame = this.animation.getFramesCount() * (1.0f - ((timer - 30) / 220.0f));
	}
	else
	{
		this.SetAnimation("shes_gonna_blow");
		this.animation.frame = this.animation.getFramesCount() * (1.0f - (timer / 30.0f));

		if (timer < 15 && timer > 0)
		{
			f32 invTimerScale = (1.0f - (timer / 15.0f));
			Vec2f scaleVec = Vec2f(1, 1) * (1.0f + 0.07f * invTimerScale * invTimerScale);
			this.ScaleBy(scaleVec);
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this is hitterBlob)
	{
		this.set_s32("bomb_timer", 0);
	}

	/*if (isExplosionHitter(customData))
	{
		return damage; //chain explosion
	}*/

	return 0.0f;
}

void onDie(CBlob@ this)
{
	this.getSprite().SetEmitSoundPaused(true);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	//special logic colliding with players
	if (blob.hasTag("player"))
	{
		const u8 hitter = this.get_u8("custom_hitter");

		//all water bombs collide with enemies
		if (hitter == Hitters::water)
			return blob.getTeamNum() != this.getTeamNum();

		//collide with shielded enemies
		return (blob.getTeamNum() != this.getTeamNum() && blob.hasTag("shielded"));
	}

	string name = blob.getName();

	if (name == "fishy" || name == "food" || name == "steak" || name == "grain" || name == "heart")
	{
		return false;
	}

	return true;
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (!solid)
	{
		return;
	}

	const f32 vellen = this.getOldVelocity().Length();
	const u8 hitter = this.get_u8("custom_hitter");
	if (vellen > 1.7f)
	{
		Sound::Play(!isExplosionHitter(hitter) ? "/WaterBubble" :
		            "/BombBounce.ogg", this.getPosition(), Maths::Min(vellen / 8.0f, 1.1f));
	}

	if (!isExplosionHitter(hitter) && !this.isAttached())
	{
		Boom(this);
		if (!this.hasTag("_hit_water") && blob !is null) //smack that mofo
		{
			this.Tag("_hit_water");
			Vec2f pos = this.getPosition();
			blob.Tag("force_knock");
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	if (!this.exists("owner blob"))
	{
	this.set_u16("owner blob", attached.getNetworkID());
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("teleport bomb"))
	{
		CBlob@ bombowner = getBlobByNetworkID(params.read_u16());
		CBlob@ bomba = getBlobByNetworkID(params.read_u16());

		if(bombowner !is null && bomba !is null)
		{
			Vec2f ourpos = bombowner.getPosition();
			Vec2f pos = this.getPosition();
			
			bombowner.setPosition(pos);
			bombowner.AddForce(Vec2f(0.01, 0));
			bombowner.getSprite().PlaySound("/Stun", 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
			setKnocked(bombowner, 2);

			CParticle@ temp = ParticleAnimated(CFileMatcher("TeamColoredLargeSmoke.png").getFirst(), pos - Vec2f(0, 8), Vec2f(0, 0), 0.0f, 1.0f, 3, 0.0f, false);

			if (temp !is null)
			{
				temp.width = 32;
				temp.height = 32;
			}

			CParticle@ temp2 = ParticleAnimated(CFileMatcher("TeamColoredLargeSmoke.png").getFirst(), ourpos - Vec2f(0, 8), Vec2f(0, 0), 0.0f, 1.0f, 3, 0.0f, false);

			if (temp2 !is null)
			{
				temp2.width = 32;
				temp2.height = 32;
			}
		}
	}
}