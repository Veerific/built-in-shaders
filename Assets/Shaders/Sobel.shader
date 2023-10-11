Shader "Unlit/Sobel"
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

            //horinzontal kernel for depth
            float DkernelH(sampler2D tex, float2 uv){

                float value[6] = { 
                0, 0, 0,
                0, 0, 0
                };

                float dValue[6] = {
                0,0,0,
                0,0,0
                };

                float3 nValue;

                value[0] = tex2D(tex, uv + fixed2(-_MainTex_TexelSize.x, -_MainTex_TexelSize.y)); //bottom left
                value[1] = tex2D(tex, uv + fixed2(-_MainTex_TexelSize.x, 0)); //mid left
                value[2] = tex2D(tex, uv + fixed2(-_MainTex_TexelSize.x, _MainTex_TexelSize.y)); //top left
                value[3] = tex2D(tex, uv + fixed2(_MainTex_TexelSize.x, -_MainTex_TexelSize.y)); //bottom right
                value[4] = tex2D(tex, uv + fixed2(_MainTex_TexelSize.x, 0)); //mid right
                value[5] = tex2D(tex, uv + fixed2(_MainTex_TexelSize.x, _MainTex_TexelSize.y)); //top right

                for(int i =0; i< 6; i++){
                    DecodeDepthNormal(value[i], dValue[i], nValue);
                }

                return dValue[0] + (2*dValue[1]) + dValue[2] + -dValue[3] + (2*-dValue[4]) + -dValue[5];            
            }

            //vertical kernel for depth
            float DkernelV(sampler2D tex, float2 uv){
                float value[6] = { 
                0, 0, 0,
                0, 0, 0
                };
                
                float dValue[6] = {
                0,0,0,
                0,0,0
                };

                float3 nValue;

             
                value[0] = tex2D(tex, uv + fixed2(-_MainTex_TexelSize.x, _MainTex_TexelSize.y)); //top left
                value[1] = tex2D(tex, uv + fixed2(0, _MainTex_TexelSize.y)); //top
                value[2] = tex2D(tex, uv + fixed2(_MainTex_TexelSize.x, _MainTex_TexelSize.y)); //top right
                value[3] = tex2D(tex, uv + fixed2(-_MainTex_TexelSize.x, -_MainTex_TexelSize.y)); //bottom left
                value[4] = tex2D(tex, uv + fixed2(0, -_MainTex_TexelSize.y)); //bottom
                value[5] = tex2D(tex, uv + fixed2(_MainTex_TexelSize.x, -_MainTex_TexelSize.y)); //bottom right
                
                for(int i =0; i< 6; i++){
                    DecodeDepthNormal(value[i], dValue[i], nValue);
                }

                return dValue[0] + (2*dValue[1]) + dValue[2] + -dValue[3] + (2*-dValue[4]) + -dValue[5];
            }

            //horinzontal kernel for normal
            float NkernelH(sampler2D tex, float2 uv){

                float value[6] = { 
                0, 0, 0,
                0, 0, 0
                };

                float3 nValue[6] = {
                float3(0,0,0),
                float3(0,0,0),
                float3(0,0,0),
                float3(0,0,0),
                float3(0,0,0),
                float3(0,0,0)
                };

                float nDot[6] = {
                0,0,0,
                0,0,0
                };
                float depthValue;

                value[0] = tex2D(tex, uv + fixed2(-_MainTex_TexelSize.x, -_MainTex_TexelSize.y)); //bottom left
                value[1] = tex2D(tex, uv + fixed2(-_MainTex_TexelSize.x, 0)); //mid left
                value[2] = tex2D(tex, uv + fixed2(-_MainTex_TexelSize.x, _MainTex_TexelSize.y)); //top left
                value[3] = tex2D(tex, uv + fixed2(_MainTex_TexelSize.x, -_MainTex_TexelSize.y)); //bottom right
                value[4] = tex2D(tex, uv + fixed2(_MainTex_TexelSize.x, 0)); //mid right
                value[5] = tex2D(tex, uv + fixed2(_MainTex_TexelSize.x, _MainTex_TexelSize.y)); //top right

                for(int i = 0; i < 6; i++){
                    DecodeDepthNormal(value[i], depthValue, nValue[i]);
                    nDot[i] = dot(nValue[i].r, nValue[i].g);
                };
                return nDot[0] + (2*nDot[1]) + nDot[2] + -nDot[3] + (2*-nDot[4]) + -nDot[5];            
            }

            //vertical kernel for normal
            float NkernelV(sampler2D tex, float2 uv){
                float value[6] = { 
                0, 0, 0,
                0, 0, 0
                };

                float3 nValue[6] = {
                float3(0,0,0),
                float3(0,0,0),
                float3(0,0,0),
                float3(0,0,0),
                float3(0,0,0),
                float3(0,0,0)
                };
                float nDot[6] = {
                0,0,0,
                0,0,0
                };
                float depthValue;

                value[0] = tex2D(tex, uv + fixed2(-_MainTex_TexelSize.x, _MainTex_TexelSize.y)); //top left
                value[1] = tex2D(tex, uv + fixed2(0, _MainTex_TexelSize.y)); //top
                value[2] = tex2D(tex, uv + fixed2(_MainTex_TexelSize.x, _MainTex_TexelSize.y)); //top right
                value[3] = tex2D(tex, uv + fixed2(-_MainTex_TexelSize.x, -_MainTex_TexelSize.y)); //bottom left
                value[4] = tex2D(tex, uv + fixed2(0, -_MainTex_TexelSize.y)); //bottom
                value[5] = tex2D(tex, uv + fixed2(_MainTex_TexelSize.x, -_MainTex_TexelSize.y)); //bottom right

                for(int i = 0; i < 6; i++){
                    DecodeDepthNormal(value[i], depthValue, nValue[i]);
                    nDot[i] = dot(nValue[i].r, nValue[i].g);
                }
                return nDot[0] + (2*nDot[1]) + nDot[2] + -nDot[3] + (2*-nDot[4]) + -nDot[5];   
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

                float depthH = DkernelH(_CameraDepthNormalsTexture, i.uv);
                float depthV = DkernelV(_CameraDepthNormalsTexture, i.uv);
                float normalH = NkernelH(_CameraDepthNormalsTexture, i.uv);
                float normalV = NkernelV(_CameraDepthNormalsTexture, i.uv);

                float oDepth = sqrt(pow(depthH, 2)+ pow(depthV, 2));
                float oNormal = sqrt(pow(normalH, 2) + pow(normalV,2));
                oDepth = oDepth > _DThreshold ? 1 : 0;
                oNormal = oNormal > _NThreshold ? 1 : 0;

                float outline = max(oDepth, oNormal);
               
                return outline + camTex;
            }
            ENDCG
        }
    }
}
