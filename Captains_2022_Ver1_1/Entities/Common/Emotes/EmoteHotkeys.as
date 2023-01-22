
#include "EmotesCommon.as";
#include "VoicelineCommon.as";

// set these so they default correctly even if we don't find the file.
u8 emote_1 = Emotes::attn;
u8 emote_2 = Emotes::smile;
u8 emote_3 = Emotes::frown;
u8 emote_4 = Emotes::mad;
u8 emote_5 = Emotes::laugh;
u8 emote_6 = Emotes::wat;
u8 emote_7 = Emotes::troll;
u8 emote_8 = Emotes::disappoint;
u8 emote_9 = Emotes::ladder;

u8 emote_10 = Emotes::flex;
u8 emote_11 = Emotes::down;
u8 emote_12 = Emotes::smug;
u8 emote_13 = Emotes::left;
u8 emote_14 = Emotes::okhand;
u8 emote_15 = Emotes::right;
u8 emote_16 = Emotes::thumbsup;
u8 emote_17 = Emotes::up;
u8 emote_18 = Emotes::thumbsdown;

const string emote_config_file = "EmoteBindings.cfg";

u8[] voiceHotkeys;
VoicelineInfo@[] all_voicelines;

bool enable_hotkeys;
bool disable_emotes;

void onInit(CBlob@ this)
{
    this.getCurrentScript().runFlags |= Script::tick_myplayer;
    this.getCurrentScript().removeIfTag = "dead";

    if(this.getPlayer() !is null)
    {
        if(!getRules().exists(this.getPlayer().getUsername() + "lastsoundplayedtime") && !getRules().exists(this.getPlayer().getUsername() + "soundcooldown"))
        {
            getRules().set_u32(this.getPlayer().getUsername() + "lastsoundplayedtime", getGameTime());
            getRules().set_u32(this.getPlayer().getUsername() + "soundcooldown", 0);
        }
    }

    this.addCommandID("prevent emotes");
    this.addCommandID("play sound ura");
    
    //attempt to load from cache first
    ConfigFile@ cfg = openEmoteBindingsConfig();
    
    emote_1 = read_emote(cfg, "emote_1", Emotes::attn);
    emote_2 = read_emote(cfg, "emote_2", Emotes::smile);
    emote_3 = read_emote(cfg, "emote_3", Emotes::frown);
    emote_4 = read_emote(cfg, "emote_4", Emotes::mad);
    emote_5 = read_emote(cfg, "emote_5", Emotes::laugh);
    emote_6 = read_emote(cfg, "emote_6", Emotes::wat);
    emote_7 = read_emote(cfg, "emote_7", Emotes::troll);
    emote_8 = read_emote(cfg, "emote_8", Emotes::disappoint);
    emote_9 = read_emote(cfg, "emote_9", Emotes::ladder);
    
    emote_10 = read_emote(cfg, "emote_10", Emotes::flex);
    emote_11 = read_emote(cfg, "emote_11", Emotes::down);
    emote_12 = read_emote(cfg, "emote_12", Emotes::smug);
    emote_13 = read_emote(cfg, "emote_13", Emotes::left);
    emote_14 = read_emote(cfg, "emote_14", Emotes::okhand);
    emote_15 = read_emote(cfg, "emote_15", Emotes::right);
    emote_16 = read_emote(cfg, "emote_16", Emotes::thumbsup);
    emote_17 = read_emote(cfg, "emote_17", Emotes::up);
    emote_18 = read_emote(cfg, "emote_18", Emotes::thumbsdown);

    ConfigFile@ cfg2 = openVoicelineConfig();

    voiceHotkeys.clear();

    for(int i = 1; i < 9; ++i)
    {
        voiceHotkeys.push_back(cfg2.read_u8("i" + i));
    }

    enable_hotkeys = cfg2.read_bool("enable key hotkeys");
    disable_emotes = cfg2.read_bool("disable emotes");

    arrayFill(all_voicelines);
}

void onReload(CBlob@ this)
{
    onInit(this);
}

void onTick(CBlob@ this)
{
    if (this.hasTag("reload emotes"))
    {
        this.Untag("reload emotes");
        onInit(this);
    }
    
    CControls@ controls = getControls();

        if (this.getTickSinceCreated() <= 1) {
        // if (this.hasTag("prevent emotes later in tick")) {
        // this.Untag("prevent emotes later in tick");
        
        // NOTE(hobey): introduced number keys for class change; but
        //      caller.SendCommand(caller.getCommandID("prevent emotes"));
        // doesn't happen in the right order for it to prevent emotes, so we do this instead to prevent emotes
        return;
    }    
    
    // TODO(hobey): @HardCodedModifierKey
    if (controls.isKeyPressed(KEY_LCONTROL) || controls.isKeyPressed(KEY_RCONTROL))
    {
        return;
    }
    if (controls.ActionKeyPressed(AK_MENU)) // NOTE(hobey): "misc" key for extra indicators
    {
        return;
    }


    
    
    if (controls.isKeyJustPressed(KEY_NUMPAD1))
    {
        set_emote(this, emote_10);
    }
    else if (controls.isKeyJustPressed(KEY_NUMPAD2))
    {
        set_emote(this, emote_11);
    }
    else if (controls.isKeyJustPressed(KEY_NUMPAD3))
    {
        set_emote(this, emote_12);
    }
    else if (controls.isKeyJustPressed(KEY_NUMPAD4))
    {
        set_emote(this, emote_13);
    }
    else if (controls.isKeyJustPressed(KEY_NUMPAD5))
    {
        set_emote(this, emote_14);
    }
    else if (controls.isKeyJustPressed(KEY_NUMPAD6))
    {
        set_emote(this, emote_15);
    }
    else if (controls.isKeyJustPressed(KEY_NUMPAD7))
    {
        set_emote(this, emote_16);
    }
    else if (controls.isKeyJustPressed(KEY_NUMPAD8))
    {
        set_emote(this, emote_17);
    }
    else if (controls.isKeyJustPressed(KEY_NUMPAD9))
    {
        set_emote(this, emote_18);
    }
    
    if (controls.ActionKeyPressed(AK_BUILD_MODIFIER))
    {
        return;
    }
    
    
    
    
    if (controls.isKeyJustPressed(KEY_KEY_1))
    {
        if(!disable_emotes || voiceHotkeys[0] > all_voicelines.size())
        set_emote(this, emote_1);
    }
    else if (controls.isKeyJustPressed(KEY_KEY_2))
    {
        if(!disable_emotes || voiceHotkeys[1] > all_voicelines.size())
        set_emote(this, emote_2);
    }
    else if (controls.isKeyJustPressed(KEY_KEY_3))
    {
        if(!disable_emotes || voiceHotkeys[2] > all_voicelines.size())
        set_emote(this, emote_3);
    }
    else if (controls.isKeyJustPressed(KEY_KEY_4))
    {
        if(!disable_emotes || voiceHotkeys[3] > all_voicelines.size())
        set_emote(this, emote_4);
    }
    else if (controls.isKeyJustPressed(KEY_KEY_5))
    {
        if(!disable_emotes || voiceHotkeys[4] > all_voicelines.size())
        set_emote(this, emote_5);
    }
    else if (controls.isKeyJustPressed(KEY_KEY_6))
    {
        if(!disable_emotes || voiceHotkeys[5] > all_voicelines.size())
        set_emote(this, emote_6);
    }
    else if (controls.isKeyJustPressed(KEY_KEY_7))
    {
        if(!disable_emotes || voiceHotkeys[6] > all_voicelines.size())
        set_emote(this, emote_7);
    }
    else if (controls.isKeyJustPressed(KEY_KEY_8))
    {
        if(!disable_emotes || voiceHotkeys[7] > all_voicelines.size())
        set_emote(this, emote_8);
    }
    else if (controls.isKeyJustPressed(KEY_KEY_9))
    {
        set_emote(this, emote_9);
    }

    CPlayer@ player = this.getPlayer();

    if(player is null) return;

    if(!enable_hotkeys) return;

    if (controls.isKeyJustPressed(KEY_KEY_1))
    {
        if(voiceHotkeys[0] < all_voicelines.size())
        {
            CBitStream params;
            params.write_u16(voiceHotkeys[0]);
            params.write_u16(player.getNetworkID());

            this.SendCommand(this.getCommandID("play sound ura"), params);
        }
    }
    else if (controls.isKeyJustPressed(KEY_KEY_2))
    {
        if(voiceHotkeys[1] < all_voicelines.size())
        {
            CBitStream params;
            params.write_u16(voiceHotkeys[1]);
            params.write_u16(player.getNetworkID());

            this.SendCommand(this.getCommandID("play sound ura"), params);
        }
    }
    else if (controls.isKeyJustPressed(KEY_KEY_3))
    {
        if(voiceHotkeys[2] < all_voicelines.size())
        {
            CBitStream params;
            params.write_u16(voiceHotkeys[2]);
            params.write_u16(player.getNetworkID());

            this.SendCommand(this.getCommandID("play sound ura"), params);
        }
    }
    else if (controls.isKeyJustPressed(KEY_KEY_4))
    {
        if(voiceHotkeys[3] < all_voicelines.size())
        {
            CBitStream params;
            params.write_u16(voiceHotkeys[3]);
            params.write_u16(player.getNetworkID());

            this.SendCommand(this.getCommandID("play sound ura"), params);
        }
    }
    else if (controls.isKeyJustPressed(KEY_KEY_5))
    {
        if(voiceHotkeys[4] < all_voicelines.size())
        {
            CBitStream params;
            params.write_u16(voiceHotkeys[4]);
            params.write_u16(player.getNetworkID());

            this.SendCommand(this.getCommandID("play sound ura"), params);
        }
    }
    else if (controls.isKeyJustPressed(KEY_KEY_6))
    {
        if(voiceHotkeys[5] < all_voicelines.size())
        {
            CBitStream params;
            params.write_u16(voiceHotkeys[5]);
            params.write_u16(player.getNetworkID());

            this.SendCommand(this.getCommandID("play sound ura"), params);
        }
    }
    else if (controls.isKeyJustPressed(KEY_KEY_7))
    {
        if(voiceHotkeys[6] < all_voicelines.size())
        {
            CBitStream params;
            params.write_u16(voiceHotkeys[6]);
            params.write_u16(player.getNetworkID());

            this.SendCommand(this.getCommandID("play sound ura"), params);
        }
    }
    else if (controls.isKeyJustPressed(KEY_KEY_8))
    {
        if(voiceHotkeys[7] < all_voicelines.size())
        {
            CBitStream params;
            params.write_u16(voiceHotkeys[7]);
            params.write_u16(player.getNetworkID());

            this.SendCommand(this.getCommandID("play sound ura"), params);
        }
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("prevent emotes"))
    {
        set_emote(this, Emotes::off);
    }
    else if (cmd == this.getCommandID("play sound ura"))
    {
        u16 index = params.read_u16();
        u16 playerid = params.read_u16();

        CPlayer@ player = getPlayerByNetworkId(playerid);

        if(player !is null)
        {
            all_voicelines[index].Play(player);
        }
    }
}


