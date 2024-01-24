Shader "ExperimentalShaders/Transparent/Cutout/Soft Edge Lit Double Sided" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
}
 
SubShader {
	Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
	LOD 200
	Cull Off
 
	Pass {
 
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite off
 
CGPROGRAM
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma fragmentoption ARB_precision_hint_fastest
#pragma multi_compile_fwdbasealpha
#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#define UNITY_PASS_FORWARDBASE
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
 
#define INTERNAL_DATA
#define WorldReflectionVector(data,normal) data.worldRefl
#define WorldNormalVector(data,normal) normal
#line 1
#line 12
 
 
sampler2D _MainTex;
fixed4 _Color;
 
struct Input {
	float2 uv_MainTex;
};
 
void surf (Input IN, inout SurfaceOutput o) {
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	o.Albedo = c.rgb;
	o.Alpha = c.a;
}
#ifdef LIGHTMAP_OFF
struct v2f_surf {
  float4 pos : SV_POSITION;
  float2 pack0 : TEXCOORD0;
  fixed3 normal : TEXCOORD1;
  fixed3 vlight : TEXCOORD2;
  LIGHTING_COORDS(3,4)
};
#endif
#ifndef LIGHTMAP_OFF
struct v2f_surf {
  float4 pos : SV_POSITION;
  float2 pack0 : TEXCOORD0;
  float2 lmap : TEXCOORD1;
  LIGHTING_COORDS(2,3)
};
#endif
#ifndef LIGHTMAP_OFF

#endif
float4 _MainTex_ST;
v2f_surf vert_surf (appdata_full v) {
  v2f_surf o;
  o.pos = UnityObjectToClipPos (v.vertex);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
  #ifndef LIGHTMAP_OFF
  o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
  #endif
  float3 worldN = mul((float3x3)unity_ObjectToWorld, SCALED_NORMAL);
  #ifdef LIGHTMAP_OFF
  o.normal = worldN;
  #endif
  #ifdef LIGHTMAP_OFF
  float3 shlight = ShadeSH9 (float4(worldN,1.0));
  o.vlight = shlight;
  #ifdef VERTEXLIGHT_ON
  float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
  o.vlight += Shade4PointLights (
    unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
    unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
    unity_4LightAtten0, worldPos, worldN );
  #endif  
  #endif  
  TRANSFER_VERTEX_TO_FRAGMENT(o);
  return o;
}
#ifndef LIGHTMAP_OFF
#ifndef DIRLIGHTMAP_OFF
#endif
#endif
fixed4 frag_surf (v2f_surf IN) : COLOR {
  Input surfIN;
  surfIN.uv_MainTex = IN.pack0.xy;
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutput o = (SurfaceOutput)0;
  #else
  SurfaceOutput o;
  #endif
  o.Albedo = 0.0;
  o.Emission = 0.0;
  o.Specular = 0.0;
  o.Alpha = 0.0;
  o.Gloss = 0.0;
  #ifdef LIGHTMAP_OFF
  o.Normal = IN.normal;
  #endif
  surf (surfIN, o);
  fixed atten = LIGHT_ATTENUATION(IN);
  fixed4 c = 0;
  #ifdef LIGHTMAP_OFF
  c = LightingLambert (o, _WorldSpaceLightPos0.xyz, atten);
  #endif  
  #ifdef LIGHTMAP_OFF
  c.rgb += o.Albedo * IN.vlight;
  #endif  
  #ifndef LIGHTMAP_OFF
  #ifdef DIRLIGHTMAP_OFF
  fixed4 lmtex = UNITY_SAMPLE_TEX2D(unity_Lightmap, IN.lmap.xy);
  fixed3 lm = DecodeLightmap (lmtex);
  #else
  fixed4 lmtex = UNITY_SAMPLE_TEX2D(unity_Lightmap, IN.lmap.xy);
  fixed4 lmIndTex = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd,unity_Lightmap, IN.lmap.xy);
  half3 lm = LightingLambert_DirLightmap(o, lmtex, lmIndTex, 0).rgb;
  #endif
  #ifdef SHADOWS_SCREEN
  #if defined(SHADER_API_GLES) && defined(SHADER_API_MOBILE)
  c.rgb += o.Albedo * min(lm, atten*2);
  #else
  c.rgb += o.Albedo * max(min(lm,(atten*2)*lmtex.rgb), lm*atten);
  #endif
  #else  
  c.rgb += o.Albedo * lm;
  #endif  
  c.a = o.Alpha;
#endif  
  c.a = o.Alpha;
  return c;
}
 
ENDCG
	} 
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }
		ColorMask RGB
CGPROGRAM
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma fragmentoption ARB_precision_hint_fastest
#pragma multi_compile_fwdbase
#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#define UNITY_PASS_FORWARDBASE
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
 
#define INTERNAL_DATA
#define WorldReflectionVector(data,normal) data.worldRefl
#define WorldNormalVector(data,normal) normal
#line 1
#line 65
 
sampler2D _MainTex;
fixed4 _Color;
 
struct Input {
	float2 uv_MainTex;
};
 
void surf (Input IN, inout SurfaceOutput o) {
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	o.Albedo = c.rgb;
	o.Alpha = c.a;
}
#ifdef LIGHTMAP_OFF
struct v2f_surf {
  float4 pos : SV_POSITION;
  float2 pack0 : TEXCOORD0;
  fixed3 normal : TEXCOORD1;
  fixed3 vlight : TEXCOORD2;
  LIGHTING_COORDS(3,4)
};
#endif
#ifndef LIGHTMAP_OFF
struct v2f_surf {
  float4 pos : SV_POSITION;
  float2 pack0 : TEXCOORD0;
  float2 lmap : TEXCOORD1;
  LIGHTING_COORDS(2,3)
};
#endif
#ifndef LIGHTMAP_OFF
#endif
float4 _MainTex_ST;
v2f_surf vert_surf (appdata_full v) {
  v2f_surf o;
  o.pos = UnityObjectToClipPos (v.vertex);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
  #ifndef LIGHTMAP_OFF
  o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
  #endif
  float3 worldN = mul((float3x3)unity_ObjectToWorld, SCALED_NORMAL);
  #ifdef LIGHTMAP_OFF
  o.normal = worldN;
  #endif
  #ifdef LIGHTMAP_OFF
  float3 shlight = ShadeSH9 (float4(worldN,1.0));
  o.vlight = shlight;
  #ifdef VERTEXLIGHT_ON
  float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
  o.vlight += Shade4PointLights (
    unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
    unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
    unity_4LightAtten0, worldPos, worldN );
  #endif  
  #endif  
  TRANSFER_VERTEX_TO_FRAGMENT(o);
  return o;
}
#ifndef LIGHTMAP_OFF
#ifndef DIRLIGHTMAP_OFF
#endif
#endif
fixed _Cutoff;
fixed4 frag_surf (v2f_surf IN) : COLOR {
  Input surfIN;
  surfIN.uv_MainTex = IN.pack0.xy;
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutput o = (SurfaceOutput)0;
  #else
  SurfaceOutput o;
  #endif
  o.Albedo = 0.0;
  o.Emission = 0.0;
  o.Specular = 0.0;
  o.Alpha = 0.0;
  o.Gloss = 0.0;
  #ifdef LIGHTMAP_OFF
  o.Normal = IN.normal;
  #endif
  surf (surfIN, o);
  clip (o.Alpha - _Cutoff);
  fixed atten = LIGHT_ATTENUATION(IN);
  fixed4 c = 0;
  #ifdef LIGHTMAP_OFF
  c = LightingLambert (o, _WorldSpaceLightPos0.xyz, atten);
  #endif  
  #ifdef LIGHTMAP_OFF
  c.rgb += o.Albedo * IN.vlight;
  #endif  
  #ifndef LIGHTMAP_OFF
  #ifdef DIRLIGHTMAP_OFF
  fixed4 lmtex = UNITY_SAMPLE_TEX2D(unity_Lightmap, IN.lmap.xy);
  fixed3 lm = DecodeLightmap (lmtex);
  #else
  fixed4 lmtex = UNITY_SAMPLE_TEX2D(unity_Lightmap, IN.lmap.xy);
  fixed4 lmIndTex = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd,unity_Lightmap, IN.lmap.xy);
  half3 lm = LightingLambert_DirLightmap(o, lmtex, lmIndTex, 0).rgb;
  #endif
  #ifdef SHADOWS_SCREEN
  #if defined(SHADER_API_GLES) && defined(SHADER_API_MOBILE)
  c.rgb += o.Albedo * min(lm, atten*2);
  #else
  c.rgb += o.Albedo * max(min(lm,(atten*2)*lmtex.rgb), lm*atten);
  #endif
  #else  
  c.rgb += o.Albedo * lm;
  #endif  
  c.a = o.Alpha;
#endif  
  c.a = o.Alpha;
  return c;
}
 
ENDCG 
}
}
Fallback "Transparent/Cutout/VertexLit"
}
