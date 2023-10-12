Shader "Unlit/RobertsCross"
{
   Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NThreshold("Normal threshold", Range(0,1)) = 0.5
        _DThreshold("Depth threshold", Range(0,1)) = 0.5
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
            sampler2D _CameraDepthTexture;
            sampler2D _CameraDepthNormalsTexture;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;

            float _DThreshold;
            float _NThreshold;

            //kernel 1
            float Dkernel1(sampler2D tex, float2 uv){

                float depth1;
                float depth2;
                float3 nValue;

                // [ value1, 0]
                // [ 0, value2]
                float value1 = tex2D(tex, uv + fixed2(0, _MainTex_TexelSize.y)); 
                float value2 = tex2D(tex, uv + fixed2(_MainTex_TexelSize.x, 0));

                DecodeDepthNormal(value1, depth1, nValue);
                DecodeDepthNormal(value2, depth2, nValue);

                return depth2 - depth1;
            }

            //kernel 2
             float Dkernel2(sampler2D tex, float2 uv){

                float depth1;
                float depth2;
                float3 nValue;

                // [ 0, value2]
                // [ value1, 0]
                float value1 = tex2D(tex, uv + fixed2(0, 0)); 
                float value2 = tex2D(tex, uv + fixed2(_MainTex_TexelSize.x, _MainTex_TexelSize.y));

                DecodeDepthNormal(value1, depth1, nValue);
                DecodeDepthNormal(value2, depth2, nValue);

                return depth2 - depth1;
            }

            //normal kernel 1
            float Nkernel1(sampler2D tex, float2 uv){

                float3 normal1;
                float3 normal2;
                float dValue;

                // [ value1, 0]
                // [ 0, value2]
                float value1 = tex2D(tex, uv + fixed2(0, _MainTex_TexelSize.y)); 
                float value2 = tex2D(tex, uv + fixed2(_MainTex_TexelSize.x, 0));

                DecodeDepthNormal(value1, dValue, normal1);
                DecodeDepthNormal(value2, dValue, normal2);

                float Ndot1 = dot(normal1.r, normal1.g);
                float Ndot2 = dot(normal2.r, normal2.g);

                return Ndot2 - Ndot1;
            }

            //normal kernel 2
             float Nkernel2(sampler2D tex, float2 uv){
             
                float3 normal1;
                float3 normal2;
                float dValue;
                // [ 0, value2]
                // [ value1, 0]
                float value1 = tex2D(tex, uv + fixed2(0, 0)); 
                float value2 = tex2D(tex, uv + fixed2(_MainTex_TexelSize.x, _MainTex_TexelSize.y));

                DecodeDepthNormal(value1, dValue, normal1);
                DecodeDepthNormal(value2, dValue, normal2);

                float Ndot1 = dot(normal1.r, normal1.g);
                float Ndot2 = dot(normal2.r, normal2.g);

                return Ndot2 - Ndot1;
            }


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
               
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                // sample the texture
                fixed4 camTex = tex2D(_MainTex, i.uv);

                float depth1 = Dkernel1(_CameraDepthNormalsTexture, i.uv);
                float depth2 = Dkernel2(_CameraDepthNormalsTexture, i.uv);
                float normal1 = Nkernel1(_CameraDepthNormalsTexture, i.uv);
                float normal2 = Nkernel2(_CameraDepthNormalsTexture, i.uv);

                float oDepth = sqrt(pow(depth1, 2)+ pow(depth2, 2));
                float oNormal = sqrt(pow(normal1, 2) + pow(normal2,2));
                oDepth = oDepth > _DThreshold ? 1 : 0;
                oNormal = oNormal > _NThreshold ? 1 : 0;

                float outline = max(oDepth, oNormal);
               
                return -outline + camTex;
            }
            ENDCG
        }
    }
}