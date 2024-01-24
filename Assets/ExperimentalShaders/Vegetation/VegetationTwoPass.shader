Shader "ExperimentalShaders/Nature/Vegetation Two Pass" {
	Properties{
		_Color("Main Color", Color) = (.5, .5, .5, .5)
		_MainTex("Base (RGB) Alpha (A)", 2D) = "white" {}
	_Cutoff("Base Alpha cutoff", Range(0,.9)) = .5
	}
		SubShader{

		Material{
		Diffuse[_Color]
		Ambient[_Color]
	}
		Lighting On

		Cull Off
		Pass{
		AlphaTest Greater[_Cutoff]
		SetTexture[_MainTex]{
		combine texture * primary, texture
	}
	}
		Pass{
		ZWrite off
		AlphaTest LEqual[_Cutoff]
		Blend SrcAlpha OneMinusSrcAlpha
		SetTexture[_MainTex]{
		combine texture * primary, texture
	}
	}
	}
}