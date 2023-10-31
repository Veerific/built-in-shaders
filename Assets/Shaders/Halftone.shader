Shader "Unlit/Halftone"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _HalfToneTex("Halftone Shadow", 2D) = "white" {}
        _HalfToneTex2("Halftone Shadow 2", 2D) = "white" {}
        _HalftoneRim("Halftone Rim", 2D) = "white" {}
        _ShadeValue("Shadow Strenght", Range(0,1)) = 0.1
        _ShadeIntensity("Shadow Intensity",Range(0,1)) = 0.1
        _ObjectColor("Color", Color) = (1,1,1,1)
        _ShadowSize("Halftone Threshold", Range(0.5,1)) = 1
        _LightSize("Light Size", Range(0,1)) = 0.5
        _Glossiness("Glossiness", Float) = 32
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
                SHADOW_COORDS(1)
                float4 pos : SV_POSITION;
                float3 worldNormal : NORMAL;
                float4 screenSpace : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
                half3 normal : TEXCOORD4;
            };

            sampler2D _MainTex;
            sampler2D _HalfToneTex;
            sampler2D _HalfToneTex2;
            sampler2D _HalftoneRim;
            float4 _MainTex_ST;
            float _ShadeValue;
            float _ShadeIntensity;
            float4 _ObjectColor;
            float _ShadowSize;
            float _LightSize;
            float _Glossiness;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.screenSpace = ComputeScreenPos(o.pos);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                o.normal = v.normal;
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the main texture
                fixed4 col = tex2D(_MainTex, i.uv);

                //screen space uvs with aspect ration in mind
                float aspect = _ScreenParams.x / _ScreenParams.y;
                fixed2 screenUV = (i.screenSpace.xy / i.screenSpace.w) * aspect;

               
                //samples halftones and gets the values via the red channel
                fixed4 halftoneTex = tex2D(_HalfToneTex, i.screenSpace);
                float halftoneVal = halftoneTex.r;

                //Light Calculation
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float shadow = SHADOW_ATTENUATION(i);
                float lightDot = dot(i.worldNormal, lightDir) * shadow;
                
                //rimlighting
                fixed2 halftoneRim = tex2D(_HalftoneRim, i.screenSpace);
                float halftoneRimVal = halftoneRim.r;
                float3 viewDir = normalize(i.viewDir);
                float viewDot = 1-dot(normalize(i.viewDir), i.worldNormal);
                float rimLight = viewDot * lightDot;
                float rim = smoothstep(_LightSize - 0.01, _LightSize + 0.01, rimLight);
                rim = step(halftoneRimVal, rim);

                ////specular Lighting
                //float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
                //float halfDot = dot(i.worldNormal, halfVector);
                //float specularIntensity = pow(halfDot + lightDot, _Glossiness * _Glossiness);
                //float specularLight = smoothstep(0.005, 0.01, specularIntensity);
               

                //Draws the halftone shadows
                if(lightDot > _ShadowSize) { lightDot = 1;}
                lightDot = lightDot > _ShadeValue ? step(halftoneVal, lightDot)  : 0;

                //Adjusts the color and intensity of the shadow
                if(lightDot == 0) {
                    lightDot = _ShadeIntensity;
                    col = (_ObjectColor * _ShadeIntensity) + col;  
                }


                
                return col * (lightDot * _LightColor0 + rim);
            }
            ENDCG
        }

        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
