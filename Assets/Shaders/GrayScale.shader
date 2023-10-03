Shader "Unlit/GrayScale"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ObjectColor("ObjectColor", Color) = (1,1,1,1)
        _LineColor("Line Color", Color) = (0,0,0,1)

        
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
            
            //Formula for calculating the relative luminance of pixels
            //Needed for grayscaling
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
            };


            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _ObjectColor;
            float _LineThreshold;
            fixed4 _LineColor;

            
            float4 _MainTex_TexelSize; // float4(1 / width, 1 / height, width, height)
            //Variables needed for Laplacian algorithm
            //It's a float3 because I don't need the alpha component
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
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 tex = tex2D(_MainTex, i.uv);

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

                float pixel_lum = saturate(u_lum + l_lum + d_lum + r_lum - (4*c_lum)); 
                pixel_lum = step(_LineThreshold, pixel_lum);
                
                fixed4 outline = fixed4(pixel_lum, pixel_lum, pixel_lum, 1);
                return -outline*2 + tex;
            }
            ENDCG
        }
    }
}
