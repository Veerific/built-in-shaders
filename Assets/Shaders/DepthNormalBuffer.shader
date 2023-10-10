Shader "Unlit/DepthNormalBuffer"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NThreshold("Normal threshold", Range(0,1)) = 0.5
        _DThreshold("Depth threshold", Range(0,1)) = 0.5
        _LineThickness("Line Thickness", Range(1,5)) = 1
        _LineColor("Outline Color", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            sampler2D _CameraDepthNormalsTexture;
            fixed4 _LineColor;
            float _LineThickness;

            fixed4 _pCenter;
            fixed4 _pRight;
            fixed4 _pLeft;
            fixed4 _pTop;
            fixed4 _pBottom;
            
            float _DThreshold;
            float _NThreshold;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
            
                // sampling the camera texture
                fixed4 mainTex = tex2D(_MainTex, i.uv);
                
                float3 normalValue0;
                float3 normalValue1;
                float3 normalValue2;
                float3 normalValue3;
                float3 normalValue4;

                float depthValue0;
                float depthValue1;
                float depthValue2;
                float depthValue3;
                float depthValue4;

                //All the Data needed for the kernel
                _pCenter = tex2D(_CameraDepthNormalsTexture, i.uv);
                _pTop = tex2D(_CameraDepthNormalsTexture, i.uv + fixed2(0,_MainTex_TexelSize.y * _LineThickness));
                _pLeft = tex2D(_CameraDepthNormalsTexture, i.uv - fixed2(_MainTex_TexelSize.x * _LineThickness, 0));
                _pBottom = tex2D(_CameraDepthNormalsTexture, i.uv - fixed2(0,_MainTex_TexelSize.y * _LineThickness));
                _pRight = tex2D(_CameraDepthNormalsTexture, i.uv + fixed2(_MainTex_TexelSize.x * _LineThickness, 0));

                DecodeDepthNormal(_pCenter, depthValue0, normalValue0);
                DecodeDepthNormal(_pTop, depthValue1, normalValue1);
                DecodeDepthNormal(_pLeft, depthValue2, normalValue2);
                DecodeDepthNormal(_pBottom, depthValue3, normalValue3);
                DecodeDepthNormal(_pRight, depthValue4, normalValue4);

                float valueC = dot(normalValue0.r, normalValue0.g);
                float valueT = dot(normalValue1.r, normalValue1.g);            
                float valueL = dot(normalValue2.r, normalValue2.g);             
                float valueB = dot(normalValue3.r, normalValue3.g);
                float valueR = dot(normalValue4.r, normalValue4.g);

                float oDepth = depthValue1 + depthValue2 + depthValue3 + depthValue4 - (4*depthValue0);
                float oNormal = valueT + valueL + valueB + valueR - 4*valueC;
                oDepth = oDepth > _DThreshold ? 1 : 0;
                oNormal = oNormal > _NThreshold ? 1 : 0;
                float outline = max(oDepth, oNormal);
               
                 if(outline == 1){
                mainTex = _LineColor;
                }

                return mainTex;
            }
            ENDCG
        }

    }
}
