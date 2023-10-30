Shader "Unlit/Halftone"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _HalfToneTex("Halftone 1", 2D) = "white" {}
        _ShadeValue("Shadow Strenght", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;             
                float4 vertex : SV_POSITION;
                float3 worldNormal : NORMAL;
            };

            sampler2D _MainTex;
            sampler2D _HalfToneTex;
            float4 _MainTex_ST;
            float _ShadeValue;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //fixed4 mask = tex2D(_HalfToneTex, i.uv);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                float lightDot = dot(i.worldNormal, lightDir);
                lightDot = smoothstep( - _ShadeValue, _ShadeValue, lightDot );
                //float lightvalues = lightDot > 0 ? 1 : _ShadeValue;

                float val = max(tex2D(_HalfToneTex, i.uv), 0.001);

                float tone = step(val, lightDot);
        

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return  tone * col;
            }
            ENDCG
        }
    }
}
