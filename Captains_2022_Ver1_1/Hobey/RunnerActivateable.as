void onInit(CBlob@ this)
{
    //these don't actually use it, they take the controls away
    this.push("names to activate", "lantern");
    this.push("names to activate", "crate");
    this.push("names to activate", "healkeg");
    this.push("names to activate", "backwallkeg");
    this.getCurrentScript().runFlags |= Script::remove_after_this;
}
