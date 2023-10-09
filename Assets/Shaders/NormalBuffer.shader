Shader "Unlit/NormalBuffer"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Threshold ("Line Threshold", Range(0,1)) = 0.5
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
                float4 screenSpace : TEXCOORD1;
                
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            sampler2D _CameraDepthNormalsTexture;
            fixed nCenter;
            fixed nUp;
            fixed nDown;
            fixed nLeft;
            fixed nRight;
            fixed normalDown;
            float _Threshold;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screenSpace = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 screenPos = i.screenSpace.xy / i.screenSpace.w;

                float3 normalValue;
                float depthValue;

                // sample the texture
                fixed4 mainTex = tex2D(_MainTex, i.uv);

                //LaplacianKernel
                nCenter = tex2D(_CameraDepthNormalsTexture, i.uv);
                nUp = tex2D(_CameraDepthNormalsTexture, i.uv + fixed2(0,_MainTex_TexelSize.y));
                nLeft = tex2D(_CameraDepthNormalsTexture, i.uv - fixed2(_MainTex_TexelSize.x, 0));
                normalDown = tex2D(_CameraDepthNormalsTexture, i.uv - fixed2(0,_MainTex_TexelSize.y));
                nRight = tex2D(_CameraDepthNormalsTexture, i.uv + fixed2(_MainTex_TexelSize.x, 0));

                //DecodeDepthNormal(nCenter, depthValue, normalValue);
                //float valueC = dot(normalValue.r, normalValue.g);

                //DecodeDepthNormal(nUp, depthValue, normalValue);
                //float valueU = dot(normalValue.r, normalValue.g);
                
                //DecodeDepthNormal(nLeft, depthValue, normalValue);
                //float valueL = dot(normalValue.r, normalValue.g);
                
                //DecodeDepthNormal(normalDown, depthValue, normalValue);
                //float valueD = dot(normalValue.r, normalValue.g);
                
                //DecodeDepthNormal(nRight, depthValue, normalValue);
                //float valueR = dot(normalValue.r, normalValue.g);

                //float outline = valueU + valueL + valueD + valueR - (4*valueC);
                //outline = outline > _Threshold ? 1 : 0;
                

                return nCenter;
            }
            ENDCG
        }
    }
}
