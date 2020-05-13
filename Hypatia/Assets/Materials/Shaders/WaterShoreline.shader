// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WaterShoreline"
{
	Properties
	{
		_WaveSpeed("WaveSpeed", Float) = 1
		_WaveDirection("Wave Direction", Vector) = (1,0,0,0)
		_WaveStretch("Wave Stretch", Vector) = (-0.29,1.37,0,0)
		_WaveTiling("WaveTiling", Float) = 1
		_WaveHeight("Wave Height", Float) = 0.5
		_Smoothness("Smoothness", Float) = 0.9
		_DarkerWater("DarkerWater", Color) = (0.2285066,0.4508401,0.745283,0)
		_BrighterWater("BrighterWater", Color) = (0.1368369,0.5204102,0.7075472,1)
		_FoamEdgeDrawDistance("Foam Edge Draw Distance ", Float) = 0.5
		_FoamPower("Foam Power", Range( 0 , 1)) = 0.5
		_Normal("Normal", 2D) = "bump" {}
		_NormalTile("NormalTile", Float) = 2.5
		_NormalStrength("NormalStrength", Range( 0 , 1)) = 1
		_NormalPanSpeed("NormalPanSpeed", Float) = 0.01
		_SeaFoam("SeaFoam", 2D) = "white" {}
		_EdgeFoarmTile("EdgeFoarmTile", Float) = 1
		_SeaFoamTile("SeaFoamTile", Float) = 2
		_RefractAmount("RefractAmount", Float) = 0.1
		_Depth("Depth", Float) = -4
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Standard keepalpha noshadow vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
		};

		uniform float _WaveSpeed;
		uniform float2 _WaveDirection;
		uniform float2 _WaveStretch;
		uniform float _WaveTiling;
		uniform float _WaveHeight;
		uniform sampler2D _Normal;
		uniform float _NormalStrength;
		uniform float _NormalPanSpeed;
		uniform float _NormalTile;
		uniform float4 _DarkerWater;
		uniform float4 _BrighterWater;
		uniform sampler2D _SeaFoam;
		uniform float _SeaFoamTile;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float _RefractAmount;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _Depth;
		uniform float _FoamEdgeDrawDistance;
		uniform float _EdgeFoarmTile;
		uniform float _FoamPower;
		uniform float _Smoothness;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			float4 temp_cast_3 = (8.0).xxxx;
			return temp_cast_3;
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float temp_output_7_0 = ( _Time.y * _WaveSpeed );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float4 appendResult10 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 WorldSpaceTile11 = appendResult10;
			float4 WaveTileUV22 = ( ( WorldSpaceTile11 * float4( _WaveStretch, 0.0 , 0.0 ) ) * _WaveTiling );
			float2 panner3 = ( temp_output_7_0 * _WaveDirection + WaveTileUV22.xy);
			float simplePerlin2D1 = snoise( panner3 );
			simplePerlin2D1 = simplePerlin2D1*0.5 + 0.5;
			float2 panner25 = ( temp_output_7_0 * _WaveDirection + ( WaveTileUV22 * float4( 0.1,0.1,0,0 ) ).xy);
			float simplePerlin2D27 = snoise( panner25 );
			simplePerlin2D27 = simplePerlin2D27*0.5 + 0.5;
			float WavesPattern32 = ( simplePerlin2D1 + simplePerlin2D27 );
			float3 WaveHeight38 = ( ( float3(0,1,0) * WavesPattern32 ) * _WaveHeight );
			v.vertex.xyz += WaveHeight38;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float4 appendResult10 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 WorldSpaceTile11 = appendResult10;
			float4 temp_output_74_0 = ( ( WorldSpaceTile11 / 10.0 ) * _NormalTile );
			float2 panner77 = ( 1.0 * _Time.y * ( float2( 1,0 ) * _NormalPanSpeed ) + temp_output_74_0.xy);
			float2 panner78 = ( 1.0 * _Time.y * ( ( _NormalPanSpeed * 2.0 ) * float2( -1,0 ) ) + temp_output_74_0.xy);
			float3 Normals90 = BlendNormals( UnpackScaleNormal( tex2D( _Normal, panner77 ), _NormalStrength ) , UnpackScaleNormal( tex2D( _Normal, panner78 ), _NormalStrength ) );
			o.Normal = Normals90;
			float4 SeaFoam114 = tex2D( _SeaFoam, ( ( WorldSpaceTile11 / 10.0 ) * _SeaFoamTile ).xy );
			float temp_output_7_0 = ( _Time.y * _WaveSpeed );
			float4 WaveTileUV22 = ( ( WorldSpaceTile11 * float4( _WaveStretch, 0.0 , 0.0 ) ) * _WaveTiling );
			float2 panner3 = ( temp_output_7_0 * _WaveDirection + WaveTileUV22.xy);
			float simplePerlin2D1 = snoise( panner3 );
			simplePerlin2D1 = simplePerlin2D1*0.5 + 0.5;
			float2 panner25 = ( temp_output_7_0 * _WaveDirection + ( WaveTileUV22 * float4( 0.1,0.1,0,0 ) ).xy);
			float simplePerlin2D27 = snoise( panner25 );
			simplePerlin2D27 = simplePerlin2D27*0.5 + 0.5;
			float WavesPattern32 = ( simplePerlin2D1 + simplePerlin2D27 );
			float clampResult46 = clamp( WavesPattern32 , 0.0 , 1.0 );
			float4 lerpResult45 = lerp( _DarkerWater , ( _BrighterWater + SeaFoam114 ) , clampResult46);
			float4 Albedo47 = lerpResult45;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor125 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( (ase_grabScreenPosNorm).xyzw * float4( ( _RefractAmount * Normals90 ) , 0.0 ) ).xy);
			float4 clampResult127 = clamp( screenColor125 , float4( 0,0,0,0 ) , float4( 1,1,1,1 ) );
			float4 Refraction126 = clampResult127;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth129 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth129 = abs( ( screenDepth129 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _Depth ) );
			float clampResult131 = clamp( ( 1.0 - distanceDepth129 ) , 0.0 , 1.0 );
			float Depth132 = clampResult131;
			float4 lerpResult133 = lerp( Albedo47 , Refraction126 , Depth132);
			o.Albedo = lerpResult133.rgb;
			float screenDepth62 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth62 = abs( ( screenDepth62 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _FoamEdgeDrawDistance ) );
			float4 clampResult64 = clamp( ( ( ( 1.0 - distanceDepth62 ) + tex2D( _SeaFoam, ( ( WorldSpaceTile11 / 10.0 ) * _EdgeFoarmTile ).xy ) ) * _FoamPower ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			float4 Edge69 = clampResult64;
			o.Emission = Edge69.rgb;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18100
1272;73;965;1049;4296.034;-2671.312;1;False;False
Node;AmplifyShaderEditor.CommentaryNode;12;-4197.126,-875.8286;Inherit;False;779.8135;257.5165;World Space UVs;3;9;10;11;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;9;-4147.126,-825.8282;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;10;-3863.249,-801.3119;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;24;-4200.137,-582.6584;Inherit;False;869.3344;421.9829;WaveTile;6;13;14;15;17;16;22;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-3641.31,-774.2145;Inherit;False;WorldSpaceTile;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;13;-4150.137,-531.3419;Inherit;True;11;WorldSpaceTile;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;14;-4127.984,-324.6764;Inherit;False;Property;_WaveStretch;Wave Stretch;2;0;Create;True;0;0;False;0;False;-0.29,1.37;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;91;-4107.315,2600.485;Inherit;False;1834.522;835.2084;Normals;19;42;72;78;77;81;74;75;73;82;84;87;71;83;79;89;88;90;93;94;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-4104.315,3078.237;Inherit;False;11;WorldSpaceTile;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-4111.905,2835.961;Inherit;False;Constant;_NumberDivider;NumberDivider;14;0;Create;True;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-3764.871,2781.785;Inherit;False;Property;_NormalPanSpeed;NormalPanSpeed;13;0;Create;True;0;0;False;0;False;0.01;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-3902.248,-323.1691;Inherit;False;Property;_WaveTiling;WaveTiling;3;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-3893.527,-526.9597;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;93;-3969.664,2968.052;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;10;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;79;-3740.17,2650.485;Inherit;False;Constant;_PanDirection;Pan Direction;12;0;Create;True;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;75;-4010.115,3172.761;Inherit;False;Property;_NormalTile;NormalTile;11;0;Create;True;0;0;False;0;False;2.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-3730.713,-526.6912;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;83;-3874.729,3271.695;Inherit;False;Constant;_PanDirection2;Pan Direction;12;0;Create;True;0;0;False;0;False;-1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-3480.903,3033.529;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-3554.801,-532.6584;Inherit;False;WaveTileUV;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-3483.033,3227.744;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-3834.834,3154;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-3460.815,2652.877;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;33;-4202.638,-126.6429;Inherit;False;1541.783;713.9842;Waves Pattern;13;29;32;27;1;25;3;31;4;23;5;28;6;7;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;71;-3807.88,2942.43;Inherit;True;Property;_Normal;Normal;10;0;Create;True;0;0;False;0;False;80452d12362cb984eb2994d421c03d85;80452d12362cb984eb2994d421c03d85;True;bump;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.PannerNode;77;-3317.49,2894.436;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;78;-3317.814,3144.278;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;115;-4581.81,1936.434;Inherit;False;1170.998;309.4869;Sea Foam;7;106;107;108;109;110;113;114;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-4072.732,195.1272;Inherit;False;Property;_WaveSpeed;WaveSpeed;0;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;5;-4103.214,37.097;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-3352.582,3027.35;Inherit;False;Property;_NormalStrength;NormalStrength;12;0;Create;True;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;28;-4152.638,422.5262;Inherit;False;22;WaveTileUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;42;-3076.247,2861.661;Inherit;True;Property;_Normals;Normals;6;0;Create;True;0;0;False;0;False;-1;80452d12362cb984eb2994d421c03d85;80452d12362cb984eb2994d421c03d85;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;72;-3075.3,3074.206;Inherit;True;Property;_Normals1;Normals;6;0;Create;True;0;0;False;0;False;-1;80452d12362cb984eb2994d421c03d85;80452d12362cb984eb2994d421c03d85;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;106;-4531.81,2012.004;Inherit;False;11;WorldSpaceTile;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-3819.998,177.3358;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;4;-3885.127,33.25575;Inherit;False;Property;_WaveDirection;Wave Direction;1;0;Create;True;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;107;-4511.307,2129.921;Inherit;False;Constant;_Float1;Float 0;15;0;Create;True;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-3885.312,-76.64287;Inherit;False;22;WaveTileUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-3894.169,427.4193;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.1,0.1,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PannerNode;25;-3628.409,428.3413;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BlendNormalsNode;88;-2729.411,2867.378;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;109;-4279.478,2015.798;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-4360.03,2126.583;Inherit;False;Property;_SeaFoamTile;SeaFoamTile;16;0;Create;True;0;0;False;0;False;2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;3;-3631.395,14.91686;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;111;-4597.002,1299.423;Inherit;False;1857.68;630.0878;EdgeFoam;15;63;96;62;97;65;67;105;66;64;69;98;102;100;101;99;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-4526.499,1813.511;Inherit;False;Constant;_Float0;Float 0;15;0;Create;True;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;96;-4249.435,1492.041;Inherit;True;Property;_SeaFoam;SeaFoam;14;0;Create;True;0;0;False;0;False;22ca8db1f1bfda649861799f23d7450e;22ca8db1f1bfda649861799f23d7450e;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;27;-3401.205,423.8823;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;-2496.793,2862.288;Inherit;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;128;-1808.66,-988.4123;Inherit;False;1284.63;455.4922;Refraction;9;120;119;124;125;127;126;121;122;123;;1,1,1,1;0;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1;-3407.506,10.25646;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;-4547.002,1695.594;Inherit;False;11;WorldSpaceTile;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-4144.359,2014.666;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;101;-4294.67,1699.388;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-1722.026,-748.9201;Inherit;False;Property;_RefractAmount;RefractAmount;17;0;Create;True;0;0;False;0;False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;122;-1715.026,-648.92;Inherit;False;90;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-4375.222,1810.173;Inherit;False;Property;_EdgeFoarmTile;EdgeFoarmTile;15;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-4165.947,1382.586;Inherit;False;Property;_FoamEdgeDrawDistance;Foam Edge Draw Distance ;8;0;Create;True;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;119;-1758.66,-936.8567;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-3054.923,296.9653;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;113;-3981.849,1986.434;Inherit;True;Property;_TextureSample1;Texture Sample 1;17;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;114;-3634.812,1986.486;Inherit;False;SeaFoam;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-1442.602,-765.6024;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-4159.552,1698.256;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-2884.855,293.3517;Inherit;False;WavesPattern;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;49;-4214.25,633.0532;Inherit;False;902.9667;636.8837;Albedo;8;44;117;116;43;47;45;46;40;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;130;-1827.195,-1280.136;Inherit;False;Property;_Depth;Depth;18;0;Create;True;0;0;False;0;False;-4;-4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;62;-3906.101,1375.909;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;120;-1501.179,-937.4617;Inherit;False;True;True;True;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;97;-3953.123,1491.064;Inherit;True;Property;_TextureSample0;Texture Sample 0;15;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;44;-4157.458,855.8107;Inherit;False;Property;_BrighterWater;BrighterWater;7;0;Create;True;0;0;False;0;False;0.1368369,0.5204102,0.7075472,1;0.1368369,0.5204102,0.7075472,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;65;-3650.537,1349.423;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;129;-1635.06,-1299.385;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;-1269.499,-931.8072;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;-4112.188,1037.592;Inherit;False;114;SeaFoam;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;39;-2608.768,40.6869;Inherit;False;1006.565;524.546;Comment;6;19;34;20;36;35;38;WaveHeight;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-4149.951,1146.205;Inherit;False;32;WavesPattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;125;-1117.265,-936.8073;Inherit;False;Global;_GrabScreen0;Grab Screen 0;18;0;Create;True;0;0;False;0;False;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;67;-3592.284,1453.84;Inherit;False;Property;_FoamPower;Foam Power;9;0;Create;True;0;0;False;0;False;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;34;-2558.768,276.2329;Inherit;True;32;WavesPattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;136;-1367.438,-1299.584;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;19;-2522.299,90.68692;Inherit;False;Constant;_Height;Height;4;0;Create;True;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ClampOpNode;46;-3952.972,1144.738;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;116;-3914.732,856.7141;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;43;-4162.4,677.9465;Inherit;False;Property;_DarkerWater;DarkerWater;6;0;Create;True;0;0;False;0;False;0.2285066,0.4508401,0.745283,0;0.2285066,0.4508401,0.745283,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;105;-3443.044,1350.462;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-3295.539,1353.991;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;131;-1158.646,-1299.136;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;127;-927.1777,-932.887;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,1;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;45;-3722.9,821.0532;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-2304.768,449.2329;Inherit;False;Property;_WaveHeight;Wave Height;4;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-2196.427,109.7342;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-3535.282,816.629;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;-748.0306,-938.4123;Inherit;False;Refraction;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-2052.768,318.2329;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;132;-973.6465,-1304.136;Inherit;False;Depth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;64;-3142.237,1354.922;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-1826.203,336.6198;Inherit;False;WaveHeight;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;134;-632.391,-266.6316;Inherit;False;126;Refraction;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;69;-2963.322,1350.053;Inherit;False;Edge;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;135;-612.391,-181.6316;Inherit;False;132;Depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;-622.2363,-345.0714;Inherit;False;47;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-447.4356,443.3954;Inherit;False;Constant;_Tesselation;Tesselation;4;0;Create;True;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;133;-391.391,-268.6316;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-456.3276,28.48334;Inherit;False;90;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-455.0253,285.8105;Inherit;False;Property;_Smoothness;Smoothness;5;0;Create;True;0;0;False;0;False;0.9;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;-471.4888,363.717;Inherit;False;38;WaveHeight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;-446.228,115.6029;Inherit;False;69;Edge;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;137;-2141.604,570.1321;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;WaterShoreline;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Translucent;0.5;True;False;0;False;Opaque;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;False;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;10;0;9;1
WireConnection;10;1;9;3
WireConnection;11;0;10;0
WireConnection;15;0;13;0
WireConnection;15;1;14;0
WireConnection;93;0;73;0
WireConnection;93;1;94;0
WireConnection;16;0;15;0
WireConnection;16;1;17;0
WireConnection;87;0;82;0
WireConnection;22;0;16;0
WireConnection;84;0;87;0
WireConnection;84;1;83;0
WireConnection;74;0;93;0
WireConnection;74;1;75;0
WireConnection;81;0;79;0
WireConnection;81;1;82;0
WireConnection;77;0;74;0
WireConnection;77;2;81;0
WireConnection;78;0;74;0
WireConnection;78;2;84;0
WireConnection;42;0;71;0
WireConnection;42;1;77;0
WireConnection;42;5;89;0
WireConnection;72;0;71;0
WireConnection;72;1;78;0
WireConnection;72;5;89;0
WireConnection;7;0;5;0
WireConnection;7;1;6;0
WireConnection;31;0;28;0
WireConnection;25;0;31;0
WireConnection;25;2;4;0
WireConnection;25;1;7;0
WireConnection;88;0;42;0
WireConnection;88;1;72;0
WireConnection;109;0;106;0
WireConnection;109;1;107;0
WireConnection;3;0;23;0
WireConnection;3;2;4;0
WireConnection;3;1;7;0
WireConnection;27;0;25;0
WireConnection;90;0;88;0
WireConnection;1;0;3;0
WireConnection;110;0;109;0
WireConnection;110;1;108;0
WireConnection;101;0;98;0
WireConnection;101;1;102;0
WireConnection;29;0;1;0
WireConnection;29;1;27;0
WireConnection;113;0;96;0
WireConnection;113;1;110;0
WireConnection;114;0;113;0
WireConnection;123;0;121;0
WireConnection;123;1;122;0
WireConnection;99;0;101;0
WireConnection;99;1;100;0
WireConnection;32;0;29;0
WireConnection;62;0;63;0
WireConnection;120;0;119;0
WireConnection;97;0;96;0
WireConnection;97;1;99;0
WireConnection;65;0;62;0
WireConnection;129;0;130;0
WireConnection;124;0;120;0
WireConnection;124;1;123;0
WireConnection;125;0;124;0
WireConnection;136;0;129;0
WireConnection;46;0;40;0
WireConnection;116;0;44;0
WireConnection;116;1;117;0
WireConnection;105;0;65;0
WireConnection;105;1;97;0
WireConnection;66;0;105;0
WireConnection;66;1;67;0
WireConnection;131;0;136;0
WireConnection;127;0;125;0
WireConnection;45;0;43;0
WireConnection;45;1;116;0
WireConnection;45;2;46;0
WireConnection;20;0;19;0
WireConnection;20;1;34;0
WireConnection;47;0;45;0
WireConnection;126;0;127;0
WireConnection;35;0;20;0
WireConnection;35;1;36;0
WireConnection;132;0;131;0
WireConnection;64;0;66;0
WireConnection;38;0;35;0
WireConnection;69;0;64;0
WireConnection;133;0;48;0
WireConnection;133;1;134;0
WireConnection;133;2;135;0
WireConnection;0;0;133;0
WireConnection;0;1;92;0
WireConnection;0;2;68;0
WireConnection;0;4;41;0
WireConnection;0;11;37;0
WireConnection;0;14;18;0
ASEEND*/
//CHKSM=F2E34D75E35012FE3CC7BDD67026867E7C982D0F