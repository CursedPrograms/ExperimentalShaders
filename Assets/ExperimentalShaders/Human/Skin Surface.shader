﻿Shader "ExperimentalShaders/Human/Skin/Surface" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_ThicknessTex("Thickness Precalc", 2D) = "black" {}
		_OcclusionTex("Occlusion Map", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
        fLTDistortion("Distortion", Range(0,2)) = 0.0
        iLTPower("Power", Range(0,50)) = 1.0
        fLTScale("Scale", Range(0,10)) = 1.0
        fLightAttentuation("Attentuation", Range(0,10)) = 1.0
        fLTAmbient("Ambient", Color) = (0,0,0,1)
        _lightPosition("LightPosition", Vector) = (0,0,0,0) 
    }
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows

		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _ThicknessTex;
		sampler2D _OcclusionTex;

        float fLTDistortion;
        float fLTScale;
        float iLTPower;
        fixed4 fLTAmbient;
        float fLightAttentuation;
        float4 _lightPosition;

		struct Input {
			float2 uv_MainTex;
		    float3 viewDir;
            float3 worldPos;
        };

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
	

        void vert (inout appdata_full v, out Input o) 
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        }

        void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed4 e = tex2D (_ThicknessTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
			o.Occlusion = tex2D(_OcclusionTex, IN.uv_MainTex);
            o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
            
            float fLTThickness = e.r;
   
            float3 lightDir = normalize(_lightPosition.xyz - IN.worldPos);
            float3 vEye =  normalize(_WorldSpaceCameraPos - IN.worldPos);

            half3 vLTLight = lightDir + o.Normal.xyz * fLTDistortion;
            half fLTDot = pow(saturate(dot(vEye, -vLTLight)), iLTPower) * fLTScale;
            half3 fLT = fLightAttentuation * (fLTDot + fLTAmbient.rgb) * fLTThickness;
            o.Emission = o.Albedo * fLT;   
        }

		ENDCG
	} 
	FallBack "Diffuse"
}
