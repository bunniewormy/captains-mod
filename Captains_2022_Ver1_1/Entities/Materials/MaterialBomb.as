
#define SERVER_ONLY

void onInit(CBlob@ this)
{
	this.maxQuantity = 1;

	if(getRules().hasTag("2bombstacks")) this.maxQuantity = 2;
	if(getRules().hasTag("3bombstacks")) this.maxQuantity = 3;

	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
