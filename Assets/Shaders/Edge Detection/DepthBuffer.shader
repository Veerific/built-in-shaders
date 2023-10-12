
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
            float _LineThreshold;

            fixed depthCenter;
            fixed depthUp;
            fixed depthDown;
            fixed depthLeft;
            fixed depthRight;
            
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

                //This is only for objects inside the scene
                //float2 screenUV = i.screenSpace.xy / i.screenSpace.w;

                //Sampling the camera depth texture
                //Linear01Depth decodes the texture 
                depthCenter = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv));
                depthUp = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + fixed2(0,_MainTex_TexelSize.y)));
                depthLeft = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv - fixed2(_MainTex_TexelSize.x, 0)));
                depthDown = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv - fixed2(0,_MainTex_TexelSize.y)));
                depthRight = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + fixed2(_MainTex_TexelSize.x, 0)));

                float pixel_lum = saturate(depthUp + depthLeft + depthDown + depthRight - (4 * depthCenter)); 
                fixed4 outline = fixed4(-pixel_lum, -pixel_lum, -pixel_lum, 1);
                return -outline;
            } 
            ENDCG
        }
    }
}
