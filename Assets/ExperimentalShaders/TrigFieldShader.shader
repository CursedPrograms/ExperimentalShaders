Shader "ExperimentalShaders/TrigField" {

Properties {
	_Color ("Color Tint", Color) = (0, 0, 0.5, 1.0)
	_Rate ("Oscillation Rate", Range (1, 10)) = 1.0
	_Scale ("Ripple Scale", Range (1, 30)) = 10.0
}

SubShader {
	
	ZWrite Off
	Tags { "Queue" = "Transparent" }
	Blend One One

	Pass {

CGPROGRAM
#pragma exclude_renderers d3d11

#define USE_TAN
#undef USE_LINES

#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_fog_exp2
#include "UnityCG.cginc"

float4 _Color;
float _Rate;
float _Scale;

struct v2f {
	float4 pos : SV_POSITION;
	float4 texcoord : TEXCOORD0;
	float4[4] target : TEXCOORD1;
};

v2f vert (appdata_base v)
{
	v2f o;
	o.pos = UnityObjectToClipPos (v.vertex);
	o.texcoord = v.texcoord;
	int j;
	for ( j = 2; j < 5; j++) {
		float a, b;
		sincos(j*_Time[0], a, b);
		o.target[j-2] = float4(a, b, 0, 0);
	}
	return o;
}

half4 frag (v2f i) : COLOR
{
	float4 d;
	int j;
	float r = _Time[1] * _Rate;
	for ( j = 0; j < 3; j++) {
#ifdef USE_LINES
#ifdef USE_TAN
		d[j] = tan(_Scale * dot(i.texcoord, i.target[j]) - r);
#else
		d[j] = sin(_Scale * dot(i.texcoord, i.target[j]) - r) * 3;
#endif
#else
#ifdef USE_TAN
		d[j] = tan(_Scale * distance(i.texcoord, i.target[j]) - r);
#else
		d[j] = sin(_Scale * distance(i.texcoord, i.target[j]) - r) * 3;
#endif
#endif
	}  
	return half4( (dot(d, d) * _Color).xyz, 1 );
}
ENDCG

    }
}
Fallback "Transparent/Diffuse"
}