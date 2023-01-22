/*int a = 56;
int b = 96;
int c = 156;
int d = 198;
int e = 16;
int f = 48;*/

float scoreboardMargin = 52.0f;
float scrollOffset = 0.0f;
float scrollSpeed = 4.0f;
float maxMenuWidth = 700;
float screenMidX = getScreenWidth()/2;

Vec2f topleft(Maths::Max( 100, screenMidX-maxMenuWidth), 150);
Vec2f topright(Maths::Max( 100, screenMidX+maxMenuWidth), 150);

int a = Maths::Max( 100, screenMidX+maxMenuWidth) - 64;
int b = 96;
int c = 60;
int d = 78;
int e = Maths::Max( 100, screenMidX-maxMenuWidth);
int f = 48;
int g = 60;
int h = 78;
