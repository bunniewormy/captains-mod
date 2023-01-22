
#include "Hitters.as";
#include "ShieldCommon.as";
#include "FireParticle.as"
#include "ArcherCommon.as";
#include "BombCommon.as";
#include "SplashWater.as";
#include "TeamStructureNear.as";
#include "KnockedCommon.as"

const s32 bomb_fuse = 120;
const f32 arrowMediumSpeed = 8.0f;//8.0f
const f32 arrowFastSpeed = 13.0f; //13.0f
//maximum is 15 as of 22/11/12 (see ArcherCommon.as)

const f32 ARROW_PUSH_FORCE = 6.0f;
const f32 SPECIAL_HIT_SCALE = 1.0f; //special hit on food items to shoot to team-mates

const s32 FIRE_IGNITE_TIME = 5;


//Arrow logic

//blob functions
void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	ShapeConsts@ consts = shape.getConsts();
	consts.mapCollisions = false;	 // weh ave our own map collision
	consts.bullet = false;
	consts.net_threshold_multiplier = 4.0f;
	this.Tag("projectile");

	//dont collide with top of the map
	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);

	if (!this.exists("arrow type"))
	{
		this.set_u8("arrow type", ArrowType::normal);
	}

	// 20 seconds of floating around - gets cut down for fire arrow
	// in ArrowHitMap
	this.server_SetTimeToDie(20);

	const u8 arrowType = this.get_u8("arrow type");

	if (arrowType == ArrowType::bomb)			 // bomb arrow
	{
		SetupBomb(this, bomb_fuse, 48.0f, 1.5f, 20.0f, 0.5f, true);
		this.set_u8("custom_hitter", Hitters::bomb_arrow);
	}

	if (arrowType == ArrowType::water || arrowType == ArrowType::heal)
	{
		this.Tag("splash ray cast");
	}

	CSprite@ sprite = this.getSprite();
	//set a random frame
	{
		Animation@ anim = sprite.addAnimation("arrow", 0, false);
		anim.AddFrame(XORRandom(4));
		sprite.SetAnimation(anim);
	}

	{
		Animation@ anim = sprite.addAnimation("water arrow", 0, false);
		anim.AddFrame(9);
		if (arrowType == ArrowType::water)
			sprite.SetAnimation(anim);
	}

	{
		Animation@ anim = sprite.addAnimation("fire arrow", 0, false);
		anim.AddFrame(8);
		if (arrowType == ArrowType::fire)
			sprite.SetAnimation(anim);
	}

	{
		Animation@ anim = sprite.addAnimation("bomb arrow", 0, false);
		anim.AddFrame(14);
		anim.AddFrame(15); //TODO flash this frame before exploding
		if (arrowType == ArrowType::bomb)
			sprite.SetAnimation(anim);
	}

	{
		Animation@ anim = sprite.addAnimation("heal arrow", 0, false);
		anim.AddFrame(16);
		if (arrowType == ArrowType::heal)
			sprite.SetAnimation(anim);
	}

	if (getMap() is null) return;
	HitInfo@[] hitInfos;
	Vec2f vel = this.getPosition() + this.getVelocity();
	if (getMap().getHitInfosFromRay(this.getOldPosition(), -vel.AngleDegrees(), vel.Length(), this, hitInfos))
	{
		for (int i = 0; i < hitInfos.size(); i++)
		{
			HitInfo@ info = hitInfos[i];
			if (info is null) continue;
			CBlob@ blob = info.blob;

			onCollision(this, blob, false, Vec2f(0,0), info.hitpos);

		}
	}
}

void turnOffFire(CBlob@ this)
{
	this.SetLight(false);
	this.set_u8("arrow type", ArrowType::normal);
	this.Untag("fire source");
	this.getSprite().SetAnimation("arrow");
	this.getSprite().PlaySound("/ExtinguishFire.ogg");
}

void turnOnFire(CBlob@ this)
{
	this.SetLight(true);
	this.set_u8("arrow type", ArrowType::fire);
	this.Tag("fire source");
	this.getSprite().SetAnimation("fire arrow");
	this.getSprite().PlaySound("/FireFwoosh.ogg");
}

void onTick(CBlob@ this)
{
	CShape@ shape = this.getShape();

	const u8 arrowType = this.get_u8("arrow type");

	f32 angle;
	bool processSticking = true;
	if (!this.hasTag("collided")) //we haven't hit anything yet!
	{
		//temp arrows arrows die in the air
		if (this.hasTag("shotgunned"))
		{
			if (this.getTickSinceCreated() > 20)
			{
				this.server_Hit(this, this.getPosition(), Vec2f(), 1.0f, Hitters::crush);
			}
		}

		//prevent leaving the map
		{
			Vec2f pos = this.getPosition();
			if (
				pos.x < 0.1f ||
				pos.x > (getMap().tilemapwidth * getMap().tilesize) - 0.1f
			) {
				this.server_Die();
				return;
			}
		}

		angle = (this.getVelocity()).Angle();
		Pierce(this);   //map
		this.setAngleDegrees(-angle);

		if (shape.vellen > 0.0001f)
		{
			if (shape.vellen > 13.5f)
				shape.SetGravityScale(0.1f);
			else
				shape.SetGravityScale(Maths::Min(1.0f, 1.0f / (shape.vellen * 0.1f)));

			processSticking = false;
		}

		// ignite arrow
		if (arrowType == ArrowType::normal && this.isInFlames())
		{
			turnOnFire(this);
		}
	}

	// sticking
	if (processSticking)
	{
		//no collision
		shape.getConsts().collidable = false;

		if (!this.hasTag("_collisions"))
		{
			this.Tag("_collisions");
			// make everyone recheck their collisions with me
			const uint count = this.getTouchingCount();
			for (uint step = 0; step < count; ++step)
			{
				CBlob@ _blob = this.getTouchingByIndex(step);
				_blob.getShape().checkCollisionsAgain = true;
			}
		}

		angle = Maths::get360DegreesFrom256(this.get_u8("angle"));
		this.setVelocity(Vec2f(0, 0));
		this.setPosition(this.get_Vec2f("lock"));
		shape.SetStatic(true);
	}

	// fire arrow
	if (arrowType == ArrowType::fire)
	{
		const s32 gametime = getGameTime();

		if (gametime % 6 == 0)
		{
			this.getSprite().SetAnimation("fire");
			this.Tag("fire source");

			Vec2f offset = Vec2f(this.getWidth(), 0.0f);
			offset.RotateBy(-angle);
			makeFireParticle(this.getPosition() + offset, 4);

			if (!this.isInWater())
			{
				this.SetLight(true);
				this.SetLightColor(SColor(255, 250, 215, 178));
				this.SetLightRadius(20.5f);
			}
			else
			{
				turnOffFire(this);
			}
		}
	}

	if (getMap() is null) return;
	HitInfo@[] hitInfos;
	Vec2f vel = this.getPosition() - this.getOldPosition();
	if (getMap().getHitInfosFromRay(this.getOldPosition(), -vel.AngleDegrees(), vel.Length(), this, hitInfos))
	{
		for (int i = 0; i < hitInfos.size(); i++)
		{
			HitInfo@ info = hitInfos[i];
			if (info is null) continue;
			CBlob@ blob = info.blob;
			if (blob is null) continue;

			if (blob.isAttachedToPoint("PICKUP"))
			{
				continue;
			}
			onCollision(this, blob, false, Vec2f(0,0), info.hitpos);

		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob !is null && doesCollideWithBlob(this, blob) && !this.hasTag("collided"))
	{
		const u8 arrowType = this.get_u8("arrow type");

		if (arrowType == ArrowType::normal)
		{
			if (
				blob.getName() == "fireplace" &&
				blob.getSprite().isAnimation("fire") &&
				this.getTickSinceCreated() > 1 //forces player to shoot through fire
			) {
				turnOnFire(this);
			}
		}

		if (
			!solid && !blob.hasTag("flesh") &&
			!specialArrowHit(blob) &&
			(blob.getName() != "mounted_bow" || this.getTeamNum() != blob.getTeamNum())
		) {
			return;
		}

		Vec2f initVelocity = this.getOldVelocity();
		f32 vellen = initVelocity.Length();
		if (vellen < 0.1f)
		{
			return;
		}

		f32 dmg = 0.0f;
		if (blob.getTeamNum() != this.getTeamNum())
		{
			dmg = getArrowDamage(this, vellen);
		}

		if (arrowType == ArrowType::water)
		{
			blob.Tag("force_knock"); //stun on collide
			this.server_Die();
			return;
		}
		else if (arrowType == ArrowType::heal)
		{
			this.server_Die();
			return;
		}
		else if (arrowType == ArrowType::bomb)
		{
			//apply a hard hit
			dmg = 1.5f;

			//move backwards a smidge for non-static bodies
			//  we use the velocity instead of the normal because we
			//  _might_ be past the middle of the object if we're going fast enough
			//  we use between old and new position because old has not been interfered with
			//  but might be too far behind (and we move back by velocity anyway)
			CShape@ shape = blob.getShape();
			if (shape !is null && !shape.isStatic())
			{
				Vec2f velnorm = this.getVelocity();
				float vellen = Maths::Min(this.getRadius(), velnorm.Normalize() * (1.0f / 30.0f));
				Vec2f betweenpos = (this.getPosition() + this.getOldPosition()) * 0.5;
				this.setPosition(betweenpos - (velnorm * vellen));
			}
		}
		else
		{
			// this isnt synced cause we want instant collision for arrow even if it was wrong
			dmg = ArrowHitBlob(this, point1, initVelocity, dmg, blob, Hitters::arrow, arrowType);
		}

		if (dmg > 0.0f)
		{
			//determine the hit type
			const u8 hit_type =
				(arrowType == ArrowType::fire) ? Hitters::fire :
				(arrowType == ArrowType::bomb) ? Hitters::bomb_arrow :
				Hitters::arrow;

			//perform the hit and tag so that another doesn't happen
			this.server_Hit(blob, point1, initVelocity, dmg, hit_type);
			this.Tag("collided");
		}

		//die _now_ for bomb arrow
		if (arrowType == ArrowType::bomb)
		{
			if (!this.hasTag("dead"))
			{
				this.doTickScripts = false;
				this.server_Die(); //explode
			}
			this.Tag("dead");
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	const u8 arrowType = this.get_u8("arrow type");

	if (blob.hasTag("material"))
    {
        return false;
    }
	//don't collide with other projectiles
	if (blob.hasTag("projectile"))
	{
		return false;
	}

	//collide so normal arrows can be ignited
	if (blob.getName() == "fireplace")
	{
		return true;
	}

	//anything to always hit
	if (specialArrowHit(blob))
	{
		return true;
	}

	bool check = this.getTeamNum() != blob.getTeamNum() || // collide with enemy blobs
					arrowType == ArrowType::heal ||
					blob.getName() == "bridge" ||
					(blob.getName() == "keg" && !blob.isAttached() && this.hasTag("fire source")); // fire arrows collide with team kegs that arent held

	//maybe collide with team structures
	if (!check)
	{
		CShape@ shape = blob.getShape();
		check = (shape.isStatic() && !shape.getConsts().platform);
	}

	if (check)
	{
		if (
			//we've collided
			this.getShape().isStatic() ||
			this.hasTag("collided") ||
			//or they're dead
			blob.hasTag("dead") ||
			//or they ignore us
			blob.hasTag("ignore_arrow")
		) {
			return false;
		}
		else
		{
			return true;
		}
	}

	return false;
}

bool specialArrowHit(CBlob@ blob)
{
	string bname = blob.getName();
	return (bname == "fishy" && blob.hasTag("dead") || bname == "food"
		|| bname == "steak" || bname == "grain"/* || bname == "heart"*/); //no egg because logic
}

void Pierce(CBlob @this, CBlob@ blob = null)
{
	Vec2f end;
	CMap@ map = this.getMap();
	Vec2f position = blob is null ? this.getPosition() : blob.getPosition();

	if (map.rayCastSolidNoBlobs(this.getShape().getVars().oldpos, position, end))
	{
		ArrowHitMap(this, end, this.getOldVelocity(), 0.5f, Hitters::arrow);
	}
}

void AddArrowLayer(CBlob@ this, CBlob@ hitBlob, CSprite@ sprite, Vec2f worldPoint, Vec2f velocity)
{
	CSpriteLayer@ arrow = sprite.addSpriteLayer("arrow", "Entities/Items/Projectiles/Arrow.png", 16, 8, this.getTeamNum(), this.getSkinNum());

	if (arrow !is null)
	{
		Animation@ anim = arrow.addAnimation("default", 13, true);

		if (this.getSprite().animation !is null)
		{
			anim.AddFrame(4 + XORRandom(4));  //always use broken frame
		}
		else
		{
			warn("exception: arrow has no anim");
			anim.AddFrame(0);
		}

		arrow.SetAnimation(anim);
		Vec2f normal = worldPoint - hitBlob.getPosition();
		f32 len = normal.Length();
		if (len > 0.0f)
			normal /= len;
		Vec2f soffset = normal * (len + 0);

		// wow, this is shit
		// movement existing makes setfacing matter?
		if (hitBlob.getMovement() is null)
		{
			// soffset.x *= -1;
			arrow.RotateBy(180.0f, Vec2f(0, 0));
			arrow.SetFacingLeft(true);
		}
		else
		{
			soffset.x *= -1;
			arrow.SetFacingLeft(false);
		}

		arrow.SetIgnoreParentFacing(true); //dont flip when parent flips


		arrow.SetOffset(soffset);
		arrow.SetRelativeZ(-0.01f);

		f32 angle = velocity.Angle();
		arrow.RotateBy(-angle - hitBlob.getAngleDegrees(), Vec2f(0, 0));
	}
}

f32 ArrowHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData, const u8 arrowType)
{
	if (hitBlob !is null)
	{
		Pierce(this, hitBlob);
		if (this.hasTag("collided")) return 0.0f;

		// check if invincible + special -> add force here
		if (specialArrowHit(hitBlob))
		{
			const f32 scale = SPECIAL_HIT_SCALE;
			f32 force = (ARROW_PUSH_FORCE * 0.125f) * Maths::Sqrt(hitBlob.getMass() + 1) * scale;
			if (this.hasTag("bow arrow"))
			{
				force *= 1.3f;
			}

			if (this.hasTag("charged"))
			{
				force *= 2.0f;
			}

			hitBlob.AddForce(velocity * force);

			//die
			this.server_Hit(this, this.getPosition(), Vec2f(), 1.0f, Hitters::crush);
		}

		// check if shielded
		const bool hitShield = (hitBlob.hasTag("shielded") && blockAttack(hitBlob, hitBlob.getPosition() - this.getPosition(), 0.0f));
		const bool hitKeg = (hitBlob.getName() == "keg");

		// play sound
		if (!hitShield)
		{
			if (hitBlob.hasTag("flesh"))
			{
				if (velocity.Length() > arrowFastSpeed)
				{
					this.getSprite().PlaySound("ArrowHitFleshFast.ogg");
				}
				else
				{
					this.getSprite().PlaySound("ArrowHitFlesh.ogg");
				}
			}
			else
			{
				if (velocity.Length() > arrowFastSpeed)
				{
					this.getSprite().PlaySound("ArrowHitGroundFast.ogg");
				}
				else
				{
					this.getSprite().PlaySound("ArrowHitGround.ogg");
				}
			}
		}
		else if (arrowType != ArrowType::normal)
		{
			damage = 0.0f;
		}

		if (arrowType == ArrowType::fire)
		{
			this.server_SetTimeToDie(0.5f);

			if (hitBlob.getName() == "keg" && !hitBlob.hasTag("exploding"))
			{
				hitBlob.SendCommand(hitBlob.getCommandID("activate"));
			}

			this.set_Vec2f("override fire pos", hitBlob.getPosition());

			if (hitShield)
			{
				this.Tag("no fire");
				this.server_Die();
			}
			else if (hitKeg)
			{
				this.server_Die(); // so that it doesn't bounce off
			}
			else
			{
				this.server_SetTimeToDie(0.5f);
			}
		}
		else
		{
			//stick into "map" blobs
			if (hitBlob.getShape().isStatic())
			{
				ArrowHitMap(this, worldPoint, velocity, damage, Hitters::arrow);
			}
			//die otherwise
			else
			{
				//add arrow layer disabled
				/*
				CSprite@ sprite = hitBlob.getSprite();
				if (sprite !is null && !hitShield && arrowType != ArrowType::bomb)
				{
					AddArrowLayer(this, hitBlob, sprite, worldPoint, velocity);
				}*/
				this.server_Die();
			}
		}
	}

	return damage;
}

void ArrowHitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData)
{
	if (velocity.Length() > arrowFastSpeed)
	{
		this.getSprite().PlaySound("ArrowHitGroundFast.ogg");
	}
	else
	{
		this.getSprite().PlaySound("ArrowHitGround.ogg");
	}

	f32 radius = this.getRadius();

	f32 angle = velocity.Angle();

	this.set_u8("angle", Maths::get256DegreesFrom360(angle));

	Vec2f norm = velocity;
	norm.Normalize();
	norm *= radius;
	Vec2f lock = worldPoint - norm;
	this.set_Vec2f("lock", lock);

	this.Sync("lock", true);
	this.Sync("angle", true);

	this.setVelocity(Vec2f(0, 0));
	this.setPosition(lock);
	//this.getShape().server_SetActive( false );

	this.Tag("collided");

	const u8 arrowType = this.get_u8("arrow type");
	if (arrowType == ArrowType::bomb)
	{
		if (!this.hasTag("dead"))
		{
			this.Tag("dead");
			this.doTickScripts = false;
			this.server_Die(); //explode
		}
	}
	else if (arrowType == ArrowType::water || arrowType == ArrowType::heal)
	{
		this.server_Die();
	}
	else if (arrowType == ArrowType::fire)
	{
		this.server_SetTimeToDie(FIRE_IGNITE_TIME);
	}

	//kill any grain plants we shot the base of
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(worldPoint, this.getRadius() * 1.3f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob @b = blobsInRadius[i];
			if (b.getName() == "grain_plant")
			{
				this.server_Hit(b, worldPoint, Vec2f(0, 0), velocity.Length() / 7.0f, Hitters::arrow);
				break;
			}
		}
	}
}

void FireUp(CBlob@ this)
{
	CMap@ map = getMap();
	if (map is null) return;

	Vec2f pos = this.getPosition();
	Vec2f head = Vec2f(map.tilesize * 0.8f, 0.0f);
	f32 angle = this.getAngleDegrees();
	head.RotateBy(angle);
	Vec2f burnpos = pos + head;

	if (this.exists("override fire pos"))
	{
		MakeFireCross(this, this.get_Vec2f("override fire pos"));
	}
	else if (isFlammableAt(burnpos))
	{
		MakeFireCross(this, burnpos);
	}
	else if (isFlammableAt(pos))
	{
		MakeFireCross(this, pos);
	}
}

void MakeFireCross(CBlob@ this, Vec2f burnpos)
{
	/*
	fire starting pattern
	X -> fire | O -> not fire

	[O] [X] [O]
	[X] [X] [X]
	[O] [X] [O]
	*/

	CMap@ map = getMap();

	const float ts = map.tilesize;

	//align to grid
	burnpos = Vec2f(
		(Maths::Floor(burnpos.x / ts) + 0.5f) * ts,
		(Maths::Floor(burnpos.y / ts) + 0.5f) * ts
	);

	Vec2f[] positions = {
		burnpos, // center
		burnpos - Vec2f(ts, 0.0f), // left
		burnpos + Vec2f(ts, 0.0f), // right
		burnpos - Vec2f(0.0f, ts), // up
		burnpos + Vec2f(0.0f, ts) // down
	};

	for (int i = 0; i < positions.length; i++)
	{
		Vec2f pos = positions[i];
		//set map on fire
		map.server_setFireWorldspace(pos, true);

		//set blob on fire
		CBlob@ b = map.getBlobAtPosition(pos);
		//skip self or nothing there
		if (b is null || b is this) continue;

		//only hit static blobs
		CShape@ s = b.getShape();
		if (s !is null && s.isStatic())
		{
			this.server_Hit(b, this.getPosition(), this.getVelocity(), 0.5f, Hitters::fire);
		}
	}
}

bool isFlammableAt(Vec2f worldPos)
{
	CMap@ map = getMap();
	//check for flammable tile
	Tile tile = map.getTile(worldPos);
	if ((tile.flags & Tile::FLAMMABLE) != 0)
	{
		return true;
	}
	//check for flammable blob
	CBlob@ b = map.getBlobAtPosition(worldPos);
	if (b !is null && b.isFlammable())
	{
		return true;
	}
	//nothing flammable here!
	return false;
}

//random object used for gib spawning
Random _gib_r(0xa7c3a);
void onDie(CBlob@ this)
{
	if (getNet().isClient())
	{
		Vec2f pos = this.getPosition();
		if (pos.x >= 1 && pos.y >= 1)
		{
			Vec2f vel = this.getVelocity();
			makeGibParticle(
				"GenericGibs.png", pos, vel,
				1, _gib_r.NextRanged(4) + 4,
				Vec2f(8, 8), 2.0f, 20, "/thud",
				this.getTeamNum()
			);
		}
	}

	const u8 arrowType = this.get_u8("arrow type");

	if (arrowType == ArrowType::fire && isServer() && !this.hasTag("no fire"))
	{
		FireUp(this);
	}

	if (arrowType == ArrowType::water)
	{
		SplashArrow(this);
	}
	if (arrowType == ArrowType::heal)
	{
		SplashHealArrow(this);
	}
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (!getNet().isServer())
	{
		return;
	}

	const u8 arrowType = this.get_u8("arrow type");
	if (arrowType == ArrowType::bomb)
	{
		return;
	}

	// merge arrow into mat_arrows

	for (int i = 0; i < inventoryBlob.getInventory().getItemsCount(); i++)
	{
		CBlob @blob = inventoryBlob.getInventory().getItem(i);

		if (blob !is this && blob.getName() == "mat_arrows")
		{
			blob.server_SetQuantity(blob.getQuantity() + 1);
			this.server_Die();
			return;
		}
	}

	// mat_arrows not found
	// make arrow into mat_arrows
	CBlob @mat = server_CreateBlob("mat_arrows");

	if (mat !is null)
	{
		inventoryBlob.server_PutInInventory(mat);
		mat.server_SetQuantity(1);
		this.server_Die();
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	const u8 arrowType = this.get_u8("arrow type");

	if (customData == Hitters::water || customData == Hitters::water_stun) //splash
	{
		if (arrowType == ArrowType::fire)
		{
			turnOffFire(this);
		}
	}

	if (customData == Hitters::sword)
	{
		return 0.0f; //no cut arrows
	}

	return damage;
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	const u8 arrowType = this.get_u8("arrow type");
	// unbomb, stick to blob
	if (this !is hitBlob && customData == Hitters::arrow)
	{
		// affect players velocity

		const f32 scale = specialArrowHit(hitBlob) ? SPECIAL_HIT_SCALE : 1.0f;

		Vec2f vel = velocity;
		const f32 speed = vel.Normalize();
		if (speed > ArcherParams::shoot_max_vel * 0.5f)
		{
			f32 force = (ARROW_PUSH_FORCE * 0.125f) * Maths::Sqrt(hitBlob.getMass() + 1) * scale;

			if (this.hasTag("bow arrow"))
			{
				force *= 1.3f;
			}

			if (this.hasTag("charged"))
			{
				force *= 2.0f;
			}

			hitBlob.AddForce(velocity * force);

			// stun if shot real close
			if (
				this.getTickSinceCreated() <= (this.hasTag("charged") ? 5 : 4)  &&
				speed > ArcherParams::shoot_max_vel * 0.845f &&
				hitBlob.hasTag("player")
			) {
				setKnocked(hitBlob, 20, true);
				Sound::Play("/Stun", hitBlob.getPosition(), 1.0f, this.getSexNum() == 0 ? 1.0f : 1.5f);
			}
		}
	}
}


f32 getArrowDamage(CBlob@ this, f32 vellen = -1.0f)
{
	if (vellen < 0) //grab it - otherwise use cached
	{
		CShape@ shape = this.getShape();
		if (shape is null)
			vellen = this.getOldVelocity().Length();
		else
			vellen = this.getShape().getVars().oldvel.Length();
	}

	if (vellen > ArcherParams::shoot_max_vel * 1.05f)
	{
		return 1.5f;
	}
	else if (vellen >= arrowFastSpeed)
	{
		return 1.0f;
	}
	else if (vellen >= arrowMediumSpeed)
	{
		return 1.0f;
	}

	return 0.5f;
}

void SplashArrow(CBlob@ this)
{
	if (!this.hasTag("splashed"))
	{
		this.Tag("splashed");
		Splash(this, 3, 3, 0.0f, true);
		this.getSprite().PlaySound("GlassBreak");
	}
}

void SplashHealArrow(CBlob@ this)
{
	if (!this.hasTag("splashed_heal"))
	{
		this.Tag("splashed_heal");

		SplashHeal(this, 3, 3, 0.0f, false);

		//Splash(this, 3, 3, 0.0f, true);

		/*Vec2f vel = this.getVelocity();
		Vec2f pos = this.getPosition();
		pos -= Vec2f(24, 24);
		for(int i=0; i<4; ++i)
		{
			for(int g=0; g<4; ++g)
			{
				Vec2f randomVel = getRandomVelocity(90, 0.5f, 40);
				CParticle@ p = ParticleAnimated("SplashHeal.png", pos,
				                                Vec2f(-vel.x, -0.4f) + randomVel, 0.0f, Maths::Max(1.0f, 0.5f * (1.0f + Maths::Abs(vel.x))),
				                                2,
				                                0.1f, false);
				if (p !is null)
				{
					p.rotates = true;
					p.rotation.y = ((XORRandom(333) > 150) ? -1.0f : 1.0f);
					p.Z = 100;
				}
				pos += Vec2f(12, 0);
			}
			pos -= Vec2f(48, 0);
			pos += Vec2f(0, 12);
		}*/

		this.getSprite().PlaySound("GlassBreak");
	}
}

void SplashHeal(CBlob@ this, const uint splash_halfwidth, const uint splash_halfheight,
            const f32 splash_offset, const bool shouldStun = true)
{
	//extinguish fire
	CMap@ map = this.getMap();
	Sound::Play("SplashSlow.ogg", this.getPosition(), 3.0f);

    //bool raycast = this.hasTag("splash ray cast");

	if (map !is null)
	{
		bool is_server = getNet().isServer();
		Vec2f pos = this.getPosition() +
		            Vec2f(this.isFacingLeft() ?
		                  -splash_halfwidth * map.tilesize*splash_offset :
		                  splash_halfwidth * map.tilesize * splash_offset,
		                  0);

		for (int x_step = -splash_halfwidth - 2; x_step < splash_halfwidth + 2; ++x_step)
		{
			for (int y_step = -splash_halfheight - 2; y_step < splash_halfheight + 2; ++y_step)
			{
				Vec2f wpos = pos + Vec2f(x_step * map.tilesize, y_step * map.tilesize);
				Vec2f outpos;

				//extinguish the fire at this pos
				if (is_server)
				{
					map.server_setFireWorldspace(wpos, false);
				}

				//make a splash!
				bool random_fact = ((x_step + y_step + getGameTime() + 125678) % 7 > 3);

				if (x_step >= -splash_halfwidth && x_step < splash_halfwidth &&
				        y_step >= -splash_halfheight && y_step < splash_halfheight &&
				        (random_fact || y_step == 0 || x_step == 0))
				{
					Vec2f randomVel = getRandomVelocity(90, 0.5f, 40);
					Vec2f vel = this.getVelocity();
					/*ParticleAnimated("SplashHeal.png", wpos,
				                                Vec2f(-vel.x, -0.4f) + randomVel, 0.0f, Maths::Max(1.0f, 0.5f * (1.0f + Maths::Abs(vel.x))),
				                                2,
				                                0.1f, false);*/
					Test(wpos, Vec2f(0, 10), 8.0f);
					//map.SplashEffect(wpos, Vec2f(0, 10), 8.0f);
				}
			}
		}

		const f32 radius = Maths::Max(splash_halfwidth * map.tilesize + map.tilesize, splash_halfheight * map.tilesize + map.tilesize);

		u8 hitter = shouldStun ? Hitters::water_stun : Hitters::water;

		Vec2f offset = Vec2f(splash_halfwidth * map.tilesize + map.tilesize, splash_halfheight * map.tilesize + map.tilesize);
		Vec2f tl = pos - offset * 0.5f;
		Vec2f br = pos + offset * 0.5f;
		if (is_server)
		{
			CBlob@ ownerBlob;
			CPlayer@ damagePlayer = this.getDamageOwnerPlayer();
			if (damagePlayer !is null)
			{
				@ownerBlob = damagePlayer.getBlob();
			}

			CBlob@[] blobs;
			map.getBlobsInBox(tl, br, @blobs);
			for (uint i = 0; i < blobs.length; i++)
			{
				CBlob@ blob = blobs[i];

				bool teammate = blob.getTeamNum() == this.getTeamNum();

				if (teammate)
				{
					f32 heal_amount = blob.getInitialHealth() - blob.getHealth();
					blob.server_Heal(heal_amount * 2);
					blob.getSprite().PlaySound("/Heart.ogg", 0.5);
				}
			}
		}
	}
}

void Test(Vec2f pos, Vec2f vel, f32 radius)
{
	f32 vellen = vel.Length();

	if (vellen > 5.0f) {
		vellen = 5.0f;
	}

	int count = vellen * 5 * (radius / 10.0f);
	Vec2f hitvel, hitpos;

	for (int i = 0; i < count; i++)
	{
		hitvel = vel*-0.35f;
		hitvel.y = -Maths::Abs( hitvel.y );
		hitvel.x += 0.01f*vellen*(XORRandom(80)-40);
		hitvel.y += -0.01f*vellen*(XORRandom(80));
		hitpos = pos + hitvel;

		if (i % 3 == 0) 
		{
			CParticle@ p = ParticlePixel(hitpos, hitvel, SColor(255, 185, 80, 63), false);
		}
		else 
		{
			CParticle@ p = ParticlePixel(hitpos, hitvel, SColor(255, 159, 52, 52), false);
		}
	}
	
	//bubbles
	count /= 3;

	for (int i = 0; i < count; i++)
	{
		hitvel = Vec2f(0,vellen);
		Vec2f bubblepos = hitpos + Vec2f(XORRandom(10)-5,5+XORRandom(10));

		if (getMap().isInWater(bubblepos))
		{
			//p = CParticle::ParticleAnimatedGeneric( i % 2 == 0 ? "Sprites/Water/SmallBubble1.png" : "Sprites/Water/SmallBubble2.png", bubblepos , (hitvel*0.25f*-(1.0f/(float)(random(5)+1))).RotateBy((float)(random(50)-25)), (float)(random(30)-15) , 1.0f, 3+random(3) ,-0.2f,false);
			CParticle@ p = ParticleAnimated(i % 2 == 0 ? "Sprites/Water/SmallBubble1.png" : "Sprites/Water/SmallBubble2.png", 
													bubblepos, 
													(hitvel * 0.25f * (-(1.0f/(XORRandom(5)+1)))).RotateBy(XORRandom(50)-25), 
													XORRandom(30)-15, 
													1.0f, 
													3+XORRandom(3),
													-0.2f,
													false);

			if (p !is null)
			{
				p.damping = 0.0f;
				p.waterdamping = 0.5f;
			}
		}
	}

	//splashes
	count /= 3;

	for (int i = 0; i < count; i++)
	{
		hitvel = Vec2f(0,vellen*(XORRandom(3)+1));
		CParticle@ p = ParticleAnimated("SplashHeal.png", 
													hitpos + Vec2f(XORRandom(10)-5, XORRandom(10)),
													(hitvel * 0.25f * (-(1.0f/(XORRandom(5)+1)))).RotateBy(XORRandom(50)-25), 
													(XORRandom(30)-15), 
													1.0f, 
													2+XORRandom(3),
													0.1f,
													false);

		if (p !is null)
		{
			p.damping = 0.95f;
			p.waterdamping = 0.5f;
		}
	}
}