//#include "LoadPNGMap.as";
#include "MinimapHook.as";

void onInit(CRules@ this)
{
	this.addCommandID("send map");
}

void serialize_image(ImageData@ map, CBitStream@ stream)
{
	int width = map.width();
	int height = map.height();

	stream.write_u16(width);
	stream.write_u16(height);

	for(u16 y = 0; y < height; y++)
	{
		for(u16 x = 0; x < width; x++)
		{
			SColor pixel = map.get(x,y);
			stream.write_u8(pixel.getAlpha());
			stream.write_u8(pixel.getRed());
			stream.write_u8(pixel.getGreen());
			stream.write_u8(pixel.getBlue());
		}
	}
}

CFileImage@ deserialize_image(CBitStream@ image_stream, string name)
{
	int width = image_stream.read_u16();
	int height = image_stream.read_u16();
	CFileImage image(width, height, true);
	CFileImage image2(width, height, true);
	image.nextPixel();
	image2.nextPixel();

	for(u16 y = 0; y < height; y++)
	{	
		for(u16 x = 0; x < width; x++)
		{								
			u8 a = image_stream.read_u8();
			u8 r = image_stream.read_u8();
			u8 g = image_stream.read_u8();
			u8 b = image_stream.read_u8();
			SColor pixel(a,r,g,b);
			image.setPixelAndAdvance(pixel);
			image2.setPixelAndAdvance(pixel);
		}
	}

	if (!CFileMatcher("Maps/" + name + ".png").hasMatch())
	{
		getNet().server_SendMsg("Map not found: " + name + ".png. Created a file for future usage");
		image.setFilename(name +".png", IMAGE_FILENAME_BASE_MAPS);
		image.Save();
		name = "randomgrid_castle.png";
		getNet().server_SendMsg("Overwriting and loading randomgrid_castle.png");
		image2.setFilename(name, IMAGE_FILENAME_BASE_MAPS);
		image2.Save();
	}
	else
	{
		CFileMatcher("Maps/" + name + ".png").printMatches();
		getNet().server_SendMsg("Overwriting " + CFileMatcher(name + ".png").getFirst() + " and loading it");
		name = CFileMatcher("Maps/" + name + ".png").getFirst().replace("Maps/", "");
		printf("name: " + name);
		image.setFilename(name, IMAGE_FILENAME_BASE_MAPS);
		image.Save();
	}
	LoadMap(CFileMatcher(name).getFirst());

	return image;
}

bool onClientProcessChat( CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player )
{
	if (player is null)
		return true;

	if (player !is getLocalPlayer()) return true;

	string[]@ tokens = text_in.split(" ");
	u8 tlen = tokens.length;

	if (tokens[0] == "!loadmap" && player.isMod() && tlen >= 3)
    {
    	string mapname = tokens[1] + ".png";
    	string servermapname = tokens[2];
    	string prop_name = "ClientMap" + getGameTime();

    	if (!Texture::exists(prop_name))
    	{
			if (Texture::createFromFile(prop_name, "Maps/" + mapname))
			{
				ImageData@ map = Texture::data(prop_name);

				CBitStream params;
				params.write_string(servermapname);
				serialize_image(map, params);

				this.SendCommand(this.getCommandID("send map"), params);
			}
			else
			{
				client_AddToChat("No file with name " + mapname);
			}
		}
    }

    return true;
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if(getNet().isServer() && cmd == this.getCommandID("send map"))
	{
		CBitStream image_stream = params;
		string name = params.read_string();
		this.set_string("actual name", name);
		this.Sync("actual name", true);
		CFileImage@ server_map = deserialize_image(params, name);
	}
}