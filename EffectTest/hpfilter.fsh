varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

precision mediump float;

void main()
{
	
	vec4 color = texture2D(inputImageTexture, textureCoordinate);
	
	uint32_t height = 256;
	uint32_t width = 256;
	
	
	uint32_t a = height / 2;
	uint32_t b = width / 2;
	
	
	
	float distance = 0;
	float H = 0;
	float w = 0;
	float v = 0;
	
	if (x == 0 && y < a)
		distance = y;
	else if (x == 0 && y >= a)
		distance = 1+a - (y+1 - a);
	else if (y == 0 && x< b)
		distance = x;
	else if (y == 0 && x >= b)
		distance = 1+b - (x+1 - b);
	else if(x>0 && y>0) {
		if (y < a)
			v = y;
		else if (y >= a)
			v = a - (y - a);
		if (x < b)
			w = x;
		else if (x >= b)
			w = b - (x - b);
		
		distance = sqrt(w * w + v * v);
		
		
	}
	
	H = 1 - exp(-(distance * distance) / (2 * (d0 * d0)));
	
	color.r = color.r * H;
	color.g = color.g * H;
	color.b = color.b * H;
	
//	im.r = im.r * H;
//	im.g = im.g * H;
//	im.b = im.b * H;
	

	
	
}