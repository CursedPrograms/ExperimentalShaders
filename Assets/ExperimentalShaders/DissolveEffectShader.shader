Shader "ExperimentalShaders/Dissolve/Unlit/DissolveEffectShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex ("Texture", 2D) = "white" {}
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		_EdgeColour1 ("Edge colour 1", Color) = (1.0, 1.0, 1.0, 1.0)
		_EdgeColour2 ("Edge colour 2", Color) = (1.0, 1.0, 1.0, 1.0)
		_Level ("Dissolution level", Range (0.0, 1.0)) = 0.1
		_Edges ("Edge width", Range (0.0, 1.0)) = 0.1
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent" }
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
        	Lighting Off
        	ZWrite Off
        	Fog { Mode Off }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile DUMMY PIXELSNAP_ON
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _NoiseTex;
			float4 _EdgeColour1;
			float4 _EdgeColour2;
			float _Level;
			float _Edges;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				#ifdef PIXELSNAP_ON
                o.vertex = UnityPixelSnap (o.vertex);
                #endif

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float cutout = tex2D(_NoiseTex, i.uv).r;
				fixed4 col = tex2D(_MainTex, i.uv);

				if (cutout < _Level)
					discard;

				if(cutout < col.a && cutout < _Level + _Edges)
					col =lerp(_EdgeColour1, _EdgeColour2, (cutout-_Level)/_Edges );

				return col;
			}
			ENDCG
		}
	}
}