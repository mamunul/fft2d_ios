varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

precision mediump float;

void main()
{
	
//	gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
	
//	gl_FragColor = vec4(0.5,0.6,0.8,1.0);
//	vec4 color = ;
//	float inverted = 1.0 - color.r;
//	vec4 inverted_vec = ;
	gl_FragColor = clamp(vec4( vec3(1.0 - (texture2D(inputImageTexture, textureCoordinate)).r), 1.0), 0.0, 1.0);
	
	
}