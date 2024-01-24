Shader "ExperimentalShaders/Ultra/UltraShader" {
    Properties {
        _AO_texture ("AO_texture", 2D) = "white" {}
        _AO_boost ("AO_boost", Float ) = 1
        _Base_Color ("Base_Color", Color) = (33333,1,1,1)
        _Base_Texture ("Base_Texture", 2D) = "white" {}
        _Base_normal_Map ("Base_normal_Map", 2D) = "bump" {}
        _MaskMixer4 ("MaskMixer4", 2D) = "gray" {}
        _Mask1_color ("Mask1_color", Color) = (1,0.007352948,0.007352948,1)
        _Mask2_color ("Mask2_color", Color) = (0.05082181,0.6911765,0.1082329,1)
        _Mask3_color ("Mask3_color", Color) = (0.04974049,0.3912004,0.6764706,1)
        _Detail_Map1 ("Detail_Map1", 2D) = "gray" {}
        _DetailSpecCol1 ("DetailSpecCol1", Color) = (1,0,0,1)
        _DetailGloss1 ("DetailGloss1", Range(0, 1)) = 1
        _Detail_Norm1 ("Detail_Norm1", 2D) = "bump" {}
        _Detail1_strength ("Detail1_strength", Range(0, 1)) = 0.5
        _Detail_Map2 ("Detail_Map2", 2D) = "gray" {}
        _DetailSpecCol2 ("DetailSpecCol2", Color) = (0.1172414,1,0,1)
        _DetailGloss2 ("DetailGloss2", Range(0, 1)) = 0.7112322
        _Detail_Norm2 ("Detail_Norm2", 2D) = "bump" {}
        _Detail2_strength ("Detail2_strength", Range(0, 1)) = 0.5
        _Detail_Map3 ("Detail_Map3", 2D) = "gray" {}
        _DetailSpecCol3 ("DetailSpecCol3", Color) = (0,0,1,1)
        _DetailGloss3 ("DetailGloss3", Range(0, 1)) = 0.4144778
        _Detail_Norm3 ("Detail_Norm3", 2D) = "bump" {}
        _Detail3_strength ("Detail3_strength", Range(0, 1)) = 0.4368932
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        LOD 200
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Cull Off
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform sampler2D _MaskMixer4; uniform float4 _MaskMixer4_ST;
            uniform float4 _Mask1_color;
            uniform float4 _Mask2_color;
            uniform float4 _Mask3_color;
            uniform sampler2D _Detail_Map1; uniform float4 _Detail_Map1_ST;
            uniform sampler2D _Detail_Map2; uniform float4 _Detail_Map2_ST;
            uniform sampler2D _Detail_Map3; uniform float4 _Detail_Map3_ST;
            uniform sampler2D _Detail_Norm1; uniform float4 _Detail_Norm1_ST;
            uniform sampler2D _Detail_Norm2; uniform float4 _Detail_Norm2_ST;
            uniform sampler2D _Detail_Norm3; uniform float4 _Detail_Norm3_ST;
            uniform float _DetailGloss1;
            uniform float _DetailGloss2;
            uniform float _DetailGloss3;
            uniform float4 _DetailSpecCol1;
            uniform float4 _DetailSpecCol2;
            uniform float4 _DetailSpecCol3;
            uniform float4 _Base_Color;
            uniform sampler2D _Base_Texture; uniform float4 _Base_Texture_ST;
            uniform sampler2D _Base_normal_Map; uniform float4 _Base_normal_Map_ST;
            uniform sampler2D _AO_texture; uniform float4 _AO_texture_ST;
            uniform float _Detail1_strength;
            uniform float _Detail2_strength;
            uniform float _Detail3_strength;
            uniform float _AO_boost;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
                LIGHTING_COORDS(5,6)
                UNITY_FOG_COORDS(7)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 node_1426 = float3(0,0,1);
                float3 _Detail_Norm1_var = UnpackNormal(tex2D(_Detail_Norm1,TRANSFORM_TEX(i.uv0, _Detail_Norm1)));
                float4 _MaskMixer4_var = tex2D(_MaskMixer4,TRANSFORM_TEX(i.uv0, _MaskMixer4));
                float3 _Detail_Norm2_var = UnpackNormal(tex2D(_Detail_Norm2,TRANSFORM_TEX(i.uv0, _Detail_Norm2)));
                float3 _Detail_Norm3_var = UnpackNormal(tex2D(_Detail_Norm3,TRANSFORM_TEX(i.uv0, _Detail_Norm3)));
                float3 _Base_normal_Map_var = UnpackNormal(tex2D(_Base_normal_Map,TRANSFORM_TEX(i.uv0, _Base_normal_Map)));
                float3 node_888_nrm_base = (((lerp(node_1426,_Detail_Norm1_var.rgb,_Detail1_strength)*_MaskMixer4_var.r)+(lerp(node_1426,_Detail_Norm2_var.rgb,_Detail2_strength)*_MaskMixer4_var.g))+(lerp(node_1426,_Detail_Norm3_var.rgb,_Detail3_strength)*_MaskMixer4_var.b)) + float3(0,0,1);
                float3 node_888_nrm_detail = _Base_normal_Map_var.rgb * float3(-1,-1,1);
                float3 node_888_nrm_combined = node_888_nrm_base*dot(node_888_nrm_base, node_888_nrm_detail)/node_888_nrm_base.z - node_888_nrm_detail;
                float3 node_888 = node_888_nrm_combined;
                float3 normalLocal = node_888;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform ));   
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
                float Pi = 3.141592654;
                float InvPi = 0.31830988618;
                float gloss = saturate((((_MaskMixer4_var.r*_DetailGloss1)+(_MaskMixer4_var.g*_DetailGloss2))+(_MaskMixer4_var.b*_DetailGloss3)));
                float specPow = exp2( gloss * 10.0+1.0);
                UnityLight light;
                #ifdef LIGHTMAP_OFF
                    light.color = lightColor;
                    light.dir = lightDirection;
                    light.ndotl = LambertTerm (normalDirection, light.dir);
                #else
                    light.color = half3(0.f, 0.f, 0.f);
                    light.ndotl = 0.0f;
                    light.dir = half3(0.f, 0.f, 0.f);
                #endif
                UnityGIInput d;
                d.light = light;
                d.worldPos = i.posWorld.xyz;
                d.worldViewDir = viewDirection;
                d.atten = attenuation;
                Unity_GlossyEnvironmentData ugls_en_data;
                ugls_en_data.roughness = 1.0 - gloss;
                ugls_en_data.reflUVW = viewReflectDirection;
                UnityGI gi = UnityGlobalIllumination(d, 1, normalDirection, ugls_en_data );
                lightDirection = gi.light.dir;
                lightColor = gi.light.color;
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float LdotH = max(0.0,dot(lightDirection, halfDirection));
                float3 specularColor = (((_DetailSpecCol1.rgb*_MaskMixer4_var.r)+(_DetailSpecCol2.rgb*_MaskMixer4_var.g))+(_DetailSpecCol3.rgb*_MaskMixer4_var.b));
                float specularMonochrome = max( max(specularColor.r, specularColor.g), specularColor.b);
                float NdotV = max(0.0,dot( normalDirection, viewDirection ));
                float NdotH = max(0.0,dot( normalDirection, halfDirection ));
                float VdotH = max(0.0,dot( viewDirection, halfDirection ));
                float visTerm = SmithBeckmannVisibilityTerm( NdotL, NdotV, 1.0-gloss );
                float normTerm = max(0.0, NDFBlinnPhongNormalizedTerm(NdotH, RoughnessToSpecPower(1.0-gloss)));
                float specularPBL = max(0, (NdotL*visTerm*normTerm) * (UNITY_PI / 4) );
                float3 directSpecular = (floor(attenuation) * _LightColor0.xyz) * pow(max(0,dot(halfDirection,normalDirection)),specPow)*specularPBL*lightColor*FresnelTerm(specularColor, LdotH);
                float3 specular = directSpecular;
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                half fd90 = 0.5 + 2 * LdotH * LdotH * (1-gloss);
                float3 directDiffuse = ((1 +(fd90 - 1)*pow((1.00001-NdotL), 5)) * (1 + (fd90 - 1)*pow((1.00001-NdotV), 5)) * NdotL) * attenColor;
                float3 indirectDiffuse = float3(0,0,0);
                indirectDiffuse += UNITY_LIGHTMODEL_AMBIENT.rgb;   
                float4 _AO_texture_var = tex2D(_AO_texture,TRANSFORM_TEX(i.uv0, _AO_texture));
                float4 _Base_Texture_var = tex2D(_Base_Texture,TRANSFORM_TEX(i.uv0, _Base_Texture));
                float4 _Detail_Map1_var = tex2D(_Detail_Map1,TRANSFORM_TEX(i.uv0, _Detail_Map1));
                float4 _Detail_Map2_var = tex2D(_Detail_Map2,TRANSFORM_TEX(i.uv0, _Detail_Map2));
                float4 _Detail_Map3_var = tex2D(_Detail_Map3,TRANSFORM_TEX(i.uv0, _Detail_Map3));
                float3 diffuseColor = ((_AO_texture_var.rgb*(_AO_texture_var.rgb*_AO_boost))*saturate((_Base_Texture_var.rgb*(_Base_Color.rgb*saturate((((_Mask1_color.rgb*(_MaskMixer4_var.r*lerp(float3(1,1,1),_Detail_Map1_var.rgb,_Detail1_strength)))+(_Mask2_color.rgb*(_MaskMixer4_var.g*lerp(float3(1,1,1),_Detail_Map2_var.rgb,_Detail2_strength))))+(_Mask3_color.rgb*(_MaskMixer4_var.b*lerp(float3(1,1,1),_Detail_Map3_var.rgb,_Detail3_strength)))))))));
                diffuseColor *= 1-specularMonochrome;
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
                float3 finalColor = diffuse + specular;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        Pass {
            Name "FORWARD_DELTA"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            Cull Off
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDADD
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform sampler2D _MaskMixer4; uniform float4 _MaskMixer4_ST;
            uniform float4 _Mask1_color;
            uniform float4 _Mask2_color;
            uniform float4 _Mask3_color;
            uniform sampler2D _Detail_Map1; uniform float4 _Detail_Map1_ST;
            uniform sampler2D _Detail_Map2; uniform float4 _Detail_Map2_ST;
            uniform sampler2D _Detail_Map3; uniform float4 _Detail_Map3_ST;
            uniform sampler2D _Detail_Norm1; uniform float4 _Detail_Norm1_ST;
            uniform sampler2D _Detail_Norm2; uniform float4 _Detail_Norm2_ST;
            uniform sampler2D _Detail_Norm3; uniform float4 _Detail_Norm3_ST;
            uniform float _DetailGloss1;
            uniform float _DetailGloss2;
            uniform float _DetailGloss3;
            uniform float4 _DetailSpecCol1;
            uniform float4 _DetailSpecCol2;
            uniform float4 _DetailSpecCol3;
            uniform float4 _Base_Color;
            uniform sampler2D _Base_Texture; uniform float4 _Base_Texture_ST;
            uniform sampler2D _Base_normal_Map; uniform float4 _Base_normal_Map_ST;
            uniform sampler2D _AO_texture; uniform float4 _AO_texture_ST;
            uniform float _Detail1_strength;
            uniform float _Detail2_strength;
            uniform float _Detail3_strength;
            uniform float _AO_boost;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
                LIGHTING_COORDS(5,6)
                UNITY_FOG_COORDS(7)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 node_1426 = float3(0,0,1);
                float3 _Detail_Norm1_var = UnpackNormal(tex2D(_Detail_Norm1,TRANSFORM_TEX(i.uv0, _Detail_Norm1)));
                float4 _MaskMixer4_var = tex2D(_MaskMixer4,TRANSFORM_TEX(i.uv0, _MaskMixer4));
                float3 _Detail_Norm2_var = UnpackNormal(tex2D(_Detail_Norm2,TRANSFORM_TEX(i.uv0, _Detail_Norm2)));
                float3 _Detail_Norm3_var = UnpackNormal(tex2D(_Detail_Norm3,TRANSFORM_TEX(i.uv0, _Detail_Norm3)));
                float3 _Base_normal_Map_var = UnpackNormal(tex2D(_Base_normal_Map,TRANSFORM_TEX(i.uv0, _Base_normal_Map)));
                float3 node_888_nrm_base = (((lerp(node_1426,_Detail_Norm1_var.rgb,_Detail1_strength)*_MaskMixer4_var.r)+(lerp(node_1426,_Detail_Norm2_var.rgb,_Detail2_strength)*_MaskMixer4_var.g))+(lerp(node_1426,_Detail_Norm3_var.rgb,_Detail3_strength)*_MaskMixer4_var.b)) + float3(0,0,1);
                float3 node_888_nrm_detail = _Base_normal_Map_var.rgb * float3(-1,-1,1);
                float3 node_888_nrm_combined = node_888_nrm_base*dot(node_888_nrm_base, node_888_nrm_detail)/node_888_nrm_base.z - node_888_nrm_detail;
                float3 node_888 = node_888_nrm_combined;
                float3 normalLocal = node_888;
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform ));   
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
                float Pi = 3.141592654;
                float InvPi = 0.31830988618;
                float gloss = saturate((((_MaskMixer4_var.r*_DetailGloss1)+(_MaskMixer4_var.g*_DetailGloss2))+(_MaskMixer4_var.b*_DetailGloss3)));
                float specPow = exp2( gloss * 10.0+1.0);
                float NdotL = max(0, dot( normalDirection, lightDirection ));
                float LdotH = max(0.0,dot(lightDirection, halfDirection));
                float3 specularColor = (((_DetailSpecCol1.rgb*_MaskMixer4_var.r)+(_DetailSpecCol2.rgb*_MaskMixer4_var.g))+(_DetailSpecCol3.rgb*_MaskMixer4_var.b));
                float specularMonochrome = max( max(specularColor.r, specularColor.g), specularColor.b);
                float NdotV = max(0.0,dot( normalDirection, viewDirection ));
                float NdotH = max(0.0,dot( normalDirection, halfDirection ));
                float VdotH = max(0.0,dot( viewDirection, halfDirection ));
                float visTerm = SmithBeckmannVisibilityTerm( NdotL, NdotV, 1.0-gloss );
                float normTerm = max(0.0, NDFBlinnPhongNormalizedTerm(NdotH, RoughnessToSpecPower(1.0-gloss)));
                float specularPBL = max(0, (NdotL*visTerm*normTerm) * (UNITY_PI / 4) );
                float3 directSpecular = attenColor * pow(max(0,dot(halfDirection,normalDirection)),specPow)*specularPBL*lightColor*FresnelTerm(specularColor, LdotH);
                float3 specular = directSpecular;
                NdotL = max(0.0,dot( normalDirection, lightDirection ));
                half fd90 = 0.5 + 2 * LdotH * LdotH * (1-gloss);
                float3 directDiffuse = ((1 +(fd90 - 1)*pow((1.00001-NdotL), 5)) * (1 + (fd90 - 1)*pow((1.00001-NdotV), 5)) * NdotL) * attenColor;
                float4 _AO_texture_var = tex2D(_AO_texture,TRANSFORM_TEX(i.uv0, _AO_texture));
                float4 _Base_Texture_var = tex2D(_Base_Texture,TRANSFORM_TEX(i.uv0, _Base_Texture));
                float4 _Detail_Map1_var = tex2D(_Detail_Map1,TRANSFORM_TEX(i.uv0, _Detail_Map1));
                float4 _Detail_Map2_var = tex2D(_Detail_Map2,TRANSFORM_TEX(i.uv0, _Detail_Map2));
                float4 _Detail_Map3_var = tex2D(_Detail_Map3,TRANSFORM_TEX(i.uv0, _Detail_Map3));
                float3 diffuseColor = ((_AO_texture_var.rgb*(_AO_texture_var.rgb*_AO_boost))*saturate((_Base_Texture_var.rgb*(_Base_Color.rgb*saturate((((_Mask1_color.rgb*(_MaskMixer4_var.r*lerp(float3(1,1,1),_Detail_Map1_var.rgb,_Detail1_strength)))+(_Mask2_color.rgb*(_MaskMixer4_var.g*lerp(float3(1,1,1),_Detail_Map2_var.rgb,_Detail2_strength))))+(_Mask3_color.rgb*(_MaskMixer4_var.b*lerp(float3(1,1,1),_Detail_Map3_var.rgb,_Detail3_strength)))))))));
                diffuseColor *= 1-specularMonochrome;
                float3 diffuse = directDiffuse * diffuseColor;
                float3 finalColor = diffuse + specular;
                fixed4 finalRGBA = fixed4(finalColor * 1,0);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
