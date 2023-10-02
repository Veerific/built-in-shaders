
Shader "Unlit/DepthBuffer"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            #define LUM(c) ((c).r*.299 + (c).g*.587 + (c).b*.114)

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
            sampler2D _CameraDepthTexture;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;

            float3 _Center;
            float3 _Up;
            float3 _Left;
            float3 _Down;
            float3 _Right;
            


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
                fixed4 maintex = tex2D(_MainTex, i.uv);

                fixed2 screenUV = i.screenSpace.xy / i.screenSpace.w;

                //Depth Buffer
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenUV.xy);


                //Gets all the pixels needed for the Laplacian image kernel
                _Center = tex2D(_MainTex, i.uv).rgb;
                _Up = tex2D(_MainTex,i.uv + fixed2(0, _MainTex_TexelSize.y));
                _Left = tex2D(_MainTex, i.uv - fixed2(_MainTex_TexelSize.x, 0));
                _Down = tex2D(_MainTex, i.uv - fixed2(0, _MainTex_TexelSize.y));
                _Right = tex2D(_MainTex, i.uv + fixed2(_MainTex_TexelSize.x, 0));
                
                float4 c_lum = LUM(_Center);
                float4 u_lum = LUM(_Up);
                float4 l_lum = LUM(_Left);
                float4 d_lum = LUM(_Down);
                float4 r_lum = LUM(_Right);

                float pixel_lum = -(saturate(u_lum + l_lum + d_lum + r_lum - (4*c_lum))) * 2; 
                //pixel_lum = step(_LineThreshold, pixel_lum);
                return fixed4(depth, depth, depth, 1);
            }
            ENDCG
        }
    }
}
