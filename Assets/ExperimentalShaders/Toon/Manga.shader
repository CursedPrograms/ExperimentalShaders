Shader "ExperimentalShaders/Toon/Manga" {
    Properties {
        _Outline ("Outline", Float ) = 0
        [MaterialToggle] _Toonify ("Toonify", Float ) = 1
        _ToonifySteps ("ToonifySteps", Range(0, 10)) = 0
        _Diffuse ("Diffuse", 2D) = "white" {}
        _DiffuseTile ("DiffuseTile", Float ) = 1
        _DiffuseBrightness ("DiffuseBrightness", Float ) = 1
        [MaterialToggle] _Diffuse_Soft_Edge ("Diffuse_Soft_Edge", Float ) = 0
        _Shadow ("Shadow", 2D) = "white" {}
        _Shadow_Angle ("Shadow_Angle", Range(0, 1.567)) = 0
        _ShadowTile ("ShadowTile", Float ) = 20
        _ShadowBrightness ("ShadowBrightness", Float ) = 2
        [MaterialToggle] _Shadow_Soft_Edge ("Shadow_Soft_Edge", Float ) = 1
        _SoftEdge_Amound ("SoftEdge_Amound", Range(1, 20)) = 5
        _GlossTex ("GlossTex", 2D) = "white" {}
        _Gloss_Angle ("Gloss_Angle", Range(0, 1.567)) = 0
        _Gloss ("Gloss", Range(0, 1)) = 0.4511278
        _GlossTile ("GlossTile", Float ) = 5
        _Gloss_Ring_Inner ("Gloss_Ring_Inner", Range(1, 10)) = 2
        _Gloss_Ring_Outer ("Gloss_Ring_Outer", Range(1, 10)) = 1
        [MaterialToggle] _NoGloss ("NoGloss", Float ) = 0
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "Outline"
            Tags {
            }
            Cull Front
            
            Fog {Mode Off}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define SHOULD_SAMPLE_SH_PROBE ( defined (LIGHTMAP_OFF) )
            #include "UnityCG.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
            #pragma target 3.0
            uniform float _Outline;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.pos = UnityObjectToClipPos(float4(v.vertex.xyz + v.normal*_Outline,1));
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {

                return fixed4(float3(0,0,0),0);
            }
            ENDCG
        }
        Pass {
            Name "ForwardBase"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            Fog {Mode Off}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #define SHOULD_SAMPLE_SH_PROBE ( defined (LIGHTMAP_OFF) )
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform sampler2D _Diffuse; uniform float4 _Diffuse_ST;
            uniform float _Gloss;
            uniform sampler2D _Shadow; uniform float4 _Shadow_ST;
            uniform float _ShadowTile;
            uniform float _ShadowBrightness;
            uniform float _DiffuseBrightness;
            uniform fixed _Diffuse_Soft_Edge;
            uniform fixed _Shadow_Soft_Edge;
            uniform sampler2D _GlossTex; uniform float4 _GlossTex_ST;
            uniform float _GlossTile;
            uniform float _DiffuseTile;
            uniform float _SoftEdge_Amound;
            uniform float _Gloss_Ring_Inner;
            uniform float _Gloss_Ring_Outer;
            uniform fixed _NoGloss;
            uniform fixed _Toonify;
            uniform float _ToonifySteps;
            uniform float _Shadow_Angle;
            uniform float _Gloss_Angle;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                LIGHTING_COORDS(3,4)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = mul(unity_ObjectToWorld, float4(v.normal,0)).xyz;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos(v.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);

                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);

                float node_7062_ang = _Shadow_Angle;
                float node_7062_spd = 1.0;
                float node_7062_cos = cos(node_7062_spd*node_7062_ang);
                float node_7062_sin = sin(node_7062_spd*node_7062_ang);
                float2 node_7062_piv = float2(0,0);
                float2 node_7062 = (mul((i.uv0*_ShadowTile)-node_7062_piv,float2x2( node_7062_cos, -node_7062_sin, node_7062_sin, node_7062_cos))+node_7062_piv);
                float4 _Shadow_var = tex2D(_Shadow,TRANSFORM_TEX(node_7062, _Shadow));
                float node_197 = floor((1.0*(1.0 - dot(lightDirection,normalDirection))));
                float node_40 = max(0,dot(lightDirection,normalDirection));
                float node_1542 = saturate((node_40*_SoftEdge_Amound));
                float node_9085 = (1.0 - node_1542);
                float2 node_70 = (i.uv0*_DiffuseTile);
                float4 _Diffuse_var = tex2D(_Diffuse,TRANSFORM_TEX(node_70, _Diffuse));
                float node_7949 = (dot(_Diffuse_var.rgb,float3(0.3,0.59,0.11))*_DiffuseBrightness);
                float node_84 = (lerp( node_7949, floor(node_7949 * _ToonifySteps) / (_ToonifySteps - 1), _Toonify )*lerp( ceil(node_40), node_1542, _Diffuse_Soft_Edge )); // Diffuse Light
                float node_52 = max(0,dot(normalDirection,halfDirection));
                float node_240 = ((_Gloss*10.0)+1.0);
                float node_2321_ang = _Gloss_Angle;
                float node_2321_spd = 1.0;
                float node_2321_cos = cos(node_2321_spd*node_2321_ang);
                float node_2321_sin = sin(node_2321_spd*node_2321_ang);
                float2 node_2321_piv = float2(0.5,0.5);
                float2 node_2321 = (mul((i.uv0*_GlossTile)-node_2321_piv,float2x2( node_2321_cos, -node_2321_sin, node_2321_sin, node_2321_cos))+node_2321_piv);
                float4 _GlossTex_var = tex2D(_GlossTex,TRANSFORM_TEX(node_2321, _GlossTex));
                float node_8567 = ((pow(node_52,exp2(node_240))*_Gloss_Ring_Outer)*(dot(_GlossTex_var.rgb,float3(0.3,0.59,0.11))*0.8));
                float node_207 = (pow(node_52,exp2(node_240))*_Gloss_Ring_Inner);
                float3 emissive = ((((dot(_Shadow_var.rgb,float3(0.3,0.59,0.11))*lerp( node_197, node_9085, _Shadow_Soft_Edge ))*_ShadowBrightness)+node_84)*(node_84+lerp( (lerp(node_8567,1.0,node_8567)-lerp(node_207,0.3,node_207)), 0.0, _NoGloss )+1.0)*_LightColor0.rgb);
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
        Pass {
            Name "ForwardAdd"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            
            
            Fog { Color (0,0,0,0) }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDADD
            #define SHOULD_SAMPLE_SH_PROBE ( defined (LIGHTMAP_OFF) )
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdadd_fullshadows
            #pragma exclude_renderers xbox360 ps3 flash d3d11_9x 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform sampler2D _Diffuse; uniform float4 _Diffuse_ST;
            uniform float _Gloss;
            uniform sampler2D _Shadow; uniform float4 _Shadow_ST;
            uniform float _ShadowTile;
            uniform float _ShadowBrightness;
            uniform float _DiffuseBrightness;
            uniform fixed _Diffuse_Soft_Edge;
            uniform fixed _Shadow_Soft_Edge;
            uniform sampler2D _GlossTex; uniform float4 _GlossTex_ST;
            uniform float _GlossTile;
            uniform float _DiffuseTile;
            uniform float _SoftEdge_Amound;
            uniform float _Gloss_Ring_Inner;
            uniform float _Gloss_Ring_Outer;
            uniform fixed _NoGloss;
            uniform fixed _Toonify;
            uniform float _ToonifySteps;
            uniform float _Shadow_Angle;
            uniform float _Gloss_Angle;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                LIGHTING_COORDS(3,4)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = mul(unity_ObjectToWorld, float4(v.normal,0)).xyz;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos(v.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            fixed4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);

                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);

                float3 finalColor = 0;
                return fixed4(finalColor * 1,0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
