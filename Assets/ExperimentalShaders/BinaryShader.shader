Shader "ExperimentalShaders/Binary" {
	Properties {
		_Color ("Pre-Calculative Color", Color) = (1,1,1,1)          
		_Col1 ("Color One", Color) = (.5,.5,.5,1)           
		_Col2 ("Color Two", Color) = (0,0,0,1)          
		_Ambient("Ambient Color", Color) = (1, 1, 1, 1)     
		_Final("Final Color Multiplication", Color) = (1, 1, 1, 1)               
		_MainTex ("Base (RGB)", 2D) = "white" {}   
		_Equa ("Equality Number ", float) = 2              
		_Modulus ("Modulus Number", float) = 4              
		_Multi ("Multiplication Number ", float) = 10        
	}
}