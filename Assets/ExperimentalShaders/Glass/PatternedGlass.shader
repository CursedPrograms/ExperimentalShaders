Shader "ExperimentalShaders/Glass/PatternedGlass"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_Color("Body Color", Color) = (1, 1, 1, 1)
		_EdgeColor("Outline Color", Color) = (1, 1, 1, 1)
		_OutlineThickness("Outline Thickness", float) = 1.0
		_Pattern("Pattern Texture", 2D) = "white" {} // Add a pattern texture
		_EmissionColor("Emission Color", Color) = (1, 1, 1, 1)
		_EmissionStrength("Emission Strength", Range(0, 1)) = 1.0
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Overlay"
		}

		Pass
		{
			Cull Off
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#pragma vertex vert
			#pragma exclude_renderers gles xbox360 ps3

			#pragma fragment frag
			#pragma multi_compile_fwdbase

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texCoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : POSITION;
				float3 normal : NORMAL;
				float2 texCoord : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
			};

			sampler2D _MainTex;
			fixed4 _Color;
			fixed4 _EdgeColor;
			float _OutlineThickness;
			sampler2D _Pattern;
			fixed4 _EmissionColor;
			float _EmissionStrength;

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				float4 normal4 = float4(v.normal, 0.0);
				o.normal = normalize(mul(normal4, unity_WorldToObject).xyz);
				o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex).xyz);
				o.texCoord = v.texCoord;
				return o;
			}

			fixed4 frag(v2f i) : COLOR
			{
				fixed4 texColor = tex2D(_MainTex, i.texCoord);
				float edgeFactor = abs(dot(i.viewDir, i.normal));
				float oneMinusEdge = 1.0 - edgeFactor;
				float3 rgb = (_Color.rgb * edgeFactor) + (_EdgeColor.rgb * oneMinusEdge);
				rgb = clamp(rgb, 0, 1);
				rgb *= texColor.rgb;
				float pattern = tex2D(_Pattern, i.texCoord).r;
				rgb *= pattern;
				rgb += _EmissionColor.rgb * _EmissionStrength;
				float opacity = min(1.0, _Color.a / edgeFactor);
				opacity = pow(opacity, _OutlineThickness);
				opacity *= texColor.a;

				fixed4 output = fixed4(rgb, opacity);
				return output;
			}

			ENDCG
		}
	}
}
