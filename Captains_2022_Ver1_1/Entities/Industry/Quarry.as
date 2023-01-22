//Auto-mining quarry
//converts wood into ores

#include "GenericButtonCommon.as"

const string fuel = "mat_wood";
const string ore = "food";
const string rare_ore = "mat_bombs";

//balance
const int input = 0;					//input cost in fuel
const int output = 2;					//output amount in ore
const bool enable_rare = true;			//enable/disable
const int rare_chance = 100;				//one-in
const int rare_output = 1;				//output for rare ore
const int conversion_frequency = 40;	//how often to convert, in seconds

const int min_input = 0;

//fuel levels for animation
const int max_fuel = 0;
const int mid_fuel = -1;
const int low_fuel = -2;

//property names
const string fuel_prop = "fuel_level";
const string working_prop = "working";
const string unique_prop = "unique";

void onInit(CSprite@ this)
{
	CSpriteLayer@ belt = this.addSpriteLayer("belt", "QuarryBelt.png", 32, 32);
	if (belt !is null)
	{
		//default anim
		{
			Animation@ anim = belt.addAnimation("default", 0, true);
			int[] frames = {
				0, 1, 2, 3,
				4, 5, 6, 7,
				8, 9, 10, 11,
				12, 13
			};
			anim.AddFrames(frames);
		}
		//belt setup
		belt.SetOffset(Vec2f(-7.0f, -4.0f));
		belt.SetRelativeZ(1);
		belt.SetVisible(true);
	}

	CSpriteLayer@ wood = this.addSpriteLayer("wood", "Quarry.png", 16, 16);
	if (wood !is null)
	{
		wood.SetOffset(Vec2f(8.0f, -1.0f));
		wood.SetVisible(false);
	}

	this.SetEmitSound("/Quarry.ogg");
	this.SetEmitSoundPaused(true);
}

void onInit(CBlob@ this)
{
	//building properties
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getSprite().SetZ(-50);
	this.getShape().getConsts().mapCollisions = false;

	//gold building properties
	this.set_s32("gold building amount", 100);

	//quarry properties
	this.set_s16(fuel_prop, 0);
	this.set_bool(working_prop, false);
	this.set_u8(unique_prop, XORRandom(getTicksASecond() * conversion_frequency));
	this.set_s16("countdown", conversion_frequency);
	this.Tag("new");
	this.Tag("skip drop");

	//commands
	this.addCommandID("add fuel");
}

void onTick(CBlob@ this)
{
	//only do "real" update logic on server
	if (getNet().isServer())
	{
		if (this.get_s16("countdown") == conversion_frequency && this.hasTag("new"))
		{
			spawnOre(this);
			this.set_s16("countdown", conversion_frequency);
			this.Sync("countdown",true);
			this.Untag("new");
			this.Sync("new", true);
		}
		else
		{
			if (getGameTime() % 30 == 0) this.set_s16("countdown", this.get_s16("countdown")-1);
			this.Sync("countdown",true);
		
			int blobCount = this.get_s16(fuel_prop);
			if ((blobCount >= min_input))
			{
				this.set_bool(working_prop, true);

				//only convert every conversion_frequency seconds
				if (this.get_s16("countdown") <=0)
				{
					spawnOre(this);
					this.set_s16("countdown", conversion_frequency);
					this.Sync("countdown",true);

					if (blobCount - input < min_input)
					{
						this.set_bool(working_prop, false);
					}

					this.Sync(fuel_prop, true);
				}

				this.Sync(working_prop, true);
			}
		}
	}

	CSprite@ sprite = this.getSprite();
	if (sprite.getEmitSoundPaused())
	{
		if (this.get_bool(working_prop))
		{
			sprite.SetEmitSoundPaused(false);
		}
	}
	else if (!this.get_bool(working_prop))
	{
		sprite.SetEmitSoundPaused(true);
	}

	//update sprite based on modified or synced properties
	updateWoodLayer(this.getSprite());
	if (getGameTime() % (getTicksASecond()/2) == 0) animateBelt(this, this.get_bool(working_prop));
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	CBitStream params;
	params.write_u16(caller.getNetworkID());

	if (this.get_s16(fuel_prop) < max_fuel)
	{
		CButton@ button = caller.CreateGenericButton("$mat_wood$", Vec2f(-4.0f, 0.0f), this, this.getCommandID("add fuel"), getTranslatedString("Add fuel"), params);
		if (button !is null)
		{
			button.deleteAfterClick = false;
			button.SetEnabled(caller.hasBlob(fuel, 1));
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("add fuel"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller is null) return;

		//amount we'd _like_ to insert
		int requestedAmount = Maths::Min(250, max_fuel - this.get_s16(fuel_prop));
		//(possible with laggy commands from 2 players, faster to early out here if we can)
		if (requestedAmount <= 0) return;

		CBlob@ carried = caller.getCarriedBlob();
		//how much fuel does the caller have including what's potentially in his hand?
		int callerQuantity = caller.getInventory().getCount(fuel) + (carried !is null && carried.getName() == fuel ? carried.getQuantity() : 0);

		//amount we _can_ insert
		int ammountToStore = Maths::Min(requestedAmount, callerQuantity);
		//can we even insert anything?
		if (ammountToStore > 0)
		{
			caller.TakeBlob(fuel, ammountToStore);
			this.set_s16(fuel_prop, this.get_s16(fuel_prop) + ammountToStore);

			updateWoodLayer(this.getSprite());
		}
	}
}

void spawnOre(CBlob@ this)
{
	int blobCount = this.get_s16(fuel_prop);
	int actual_input = Maths::Min(input, blobCount);

	int r = XORRandom(rare_chance);
	//rare chance, but never rare if not a full batch of wood

	CBlob@ _ore = server_CreateBlobNoInit(ore);
	CBlob@ _ore1 = server_CreateBlobNoInit(rare_ore);

	if (_ore is null || _ore1 is null) return;

	int amountToSpawn = output;

	//setup res
	_ore.Tag("custom quantity");
	_ore.setPosition(this.getPosition() + Vec2f(-8.0f, 0.0f));
	_ore.server_SetQuantity(amountToSpawn);
	_ore.Init();

	_ore1.Tag("custom quantity");
	_ore1.setPosition(this.getPosition() + Vec2f(-8.0f, 0.0f));
	_ore1.server_SetQuantity(rare_output);
	_ore1.Init();

//	this.set_s16(fuel_prop, blobCount - actual_input); //burn wood
}

void updateWoodLayer(CSprite@ this)
{
	int wood = this.getBlob().get_s16(fuel_prop);
	CSpriteLayer@ layer = this.getSpriteLayer("wood");

	if (layer is null) return;

	if (wood < min_input)
	{
		layer.SetVisible(false);
	}
	else
	{
		layer.SetVisible(true);
		int frame = 5;
		if (wood > low_fuel) frame = 6;
		if (wood > mid_fuel) frame = 7;
		layer.SetFrameIndex(frame);
	}
}

void animateBelt(CBlob@ this, bool isActive)
{
	//safely fetch the animation to modify
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;
	CSpriteLayer@ belt = sprite.getSpriteLayer("belt");
	if (belt is null) return;
	Animation@ anim = belt.getAnimation("default");
	if (anim is null) return;

	//modify it based on activity
	if (isActive)
	{
		// slowly start animation
		if (anim.time == 0) anim.time = 6;
		if (anim.time > 3) anim.time--;
	}
	else
	{
		//(not tossing stone)
		if (anim.frame < 2 || anim.frame > 8)
		{
			// slowly stop animation
			if (anim.time == 6) anim.time = 0;
			if (anim.time > 0 && anim.time < 6) anim.time++;
		}
	}
}

string get_font(string file_name, s32 size)
{
    string result = file_name+"_"+size;
    if (!GUI::isFontLoaded(result)) {
        string full_file_name = CFileMatcher(file_name+".ttf").getFirst();
        // TODO(hobey): apparently you cannot load multiple different sizes of a font from the same font file in this api?
        GUI::LoadFont(result, full_file_name, size, true);
    }
    return result;
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Vec2f center = blob.getPosition();
	Vec2f mouseWorld = getControls().getMouseWorldPos();
	const f32 renderRadius = (blob.getRadius()) * 0.95f;
	bool mouseOnBlob = (mouseWorld - center).getLength() < renderRadius;

	if (mouseOnBlob)
	{
		Vec2f pos2d = blob.getScreenPos() - Vec2f(0, 20);

		string font_name = get_font("GenShinGothic-P-Medium", 48.0f);
		SColor text_color = SColor(255,255,255,255);

		//string timeuntilmatdrop = ""+ (getGameTime() - (getGameTime() % (conversion_frequency* getTicksASecond())) * (conversion_frequency* getTicksASecond()));
		string timeuntilmatdrop = this.getBlob().get_s16("countdown");
		GUI::DrawTextCentered(timeuntilmatdrop, pos2d, text_color);

	}
}