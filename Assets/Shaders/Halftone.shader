Shader "Unlit/Halftone"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _HalfToneTex("Halftone 1", 2D) = "white" {}
        _ShadeValue("Shadow Strenght", Range(0,1)) = 0.5
        _ShadeIntensity("Shadow Intensity",Range(0,1)) = 0.1
        _ObjectColor("Color", Color) = (1,1,1,1)
        _ShadowSize("Halftone Threshold", Range(0.5,1)) = 1
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

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap 
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                SHADOW_COORDS(2)
                float4 pos : SV_POSITION;
                float3 worldNormal : NORMAL;
                float4 screenSpace : TEXCOORD3;
            };

            sampler2D _MainTex;
            sampler2D _HalfToneTex;
            float4 _MainTex_ST;
            float _ShadeValue;
            float _ShadeIntensity;
            float4 _ObjectColor;
            float _ShadowSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.screenSpace = ComputeScreenPos(o.pos);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                float aspect = _ScreenParams.x / _ScreenParams.y;
                fixed2 screenUV = (i.screenSpace.xy / i.screenSpace.w) * aspect;
               

                fixed4 halftoneTex = tex2D(_HalfToneTex, i.screenSpace);
                float halftoneVal = halftoneTex.r;


                //fixed4 mask = tex2D(_HalfToneTex, i.uv);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float shadow = SHADOW_ATTENUATION(i);

                float lightDot = dot(i.worldNormal, lightDir) * shadow;
                //lightDot = smoothstep( -_ShadeValue, _ShadeValue, lightDot);
                
                //clamps value between 0 and 1
                //float shadeClamp = _ShadeValue * ;   
                if(lightDot > _ShadowSize) { lightDot = 1;}
                lightDot = lightDot > _ShadeValue ? step(halftoneVal, lightDot)  : 0;

                if(lightDot == 0) {
                    lightDot = _ShadeIntensity;
                    col = (_ObjectColor * _ShadeIntensity) + col;  
                }

               
            
                //float lightvalues = lightDot > 0 ? 1 : _ShadeValue;


        

                
                return col * lightDot * _LightColor0;
            }
            ENDCG
        }

        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
