#ifdef GL_ES
varying mediump vec2 v_texCoord;
varying mediump vec4 v_fragmentColor;
#else
varying vec2 v_texCoord;
varying vec4 v_fragmentColor;
#endif

void main()
{
	vec2 intXY = vec2(v_texCoord.x * 195, v_texCoord.y * 270);
	vec2 xyMosaic = vec2(int(intXY.x/20) * 20, int(intXY.y/20) * 20);
	vec2 uvMosaic = vec2(xyMosaic.x/195, xyMosaic.y/270);
	gl_FragColor = texture2D(CC_Texture0, uvMosaic);
}