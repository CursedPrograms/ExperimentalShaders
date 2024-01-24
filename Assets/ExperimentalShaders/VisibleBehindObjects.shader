Shader "ExperimentalShaders/FX/VisibleBehindObjects" 
{
Properties 
{
	_MainTex ("Base (RGB) TransGloss (A)", 2D) = "white" {}
}

SubShader 
{     

CGPROGRAM
#pragma surface surf BlinnPhong alpha

sampler2D _MainTex;

struct Input 
{
	float2 uv_MainTex;
};

void surf (Input IN, inout SurfaceOutput o)
{
	fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
}
ENDCG
}

Category 
{
    SubShader 
    {
    Tags
    {
    "Queue"="Overlay"
    "IgnoreProjector"="True"
    "RenderType"="Transparent"
    }
       	Pass
        {
            ZTest Greater
            
            AlphaTest Greater 0.5
			SetTexture [_MainTex]
			{ 
				combine texture 
			}
        }
		
        Pass 
        {
            ZTest Less
            
            AlphaTest Greater 0.5
			SetTexture [_MainTex]
			{ 
				combine texture 
			}
        }
    }
}

Fallback "Transparent/VertexLit"
}