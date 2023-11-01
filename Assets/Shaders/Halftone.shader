Shader "Unlit/Halftone"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _HalfToneTex("Halftone Shadow", 2D) = "white" {}
        _Threshold("Halftone Threshold", Range(0, 1)) = 1
        _HalfToneTex2("Halftone Shadow 2", 2D) = "white" {}
        _HalftoneRim("Halftone Rim", 2D) = "white" {}
        _LightThreshold("Light Halftone Threshold", Range(1,5)) = 1
        _ShadeValue("Shadow Strenght", Range(0,1)) = 0.1
        _ShadeIntensity("Shadow Intensity",Range(0,1)) = 0.1
        _ObjectColor("Color", Color) = (1,1,1,1)
        _ShadowSize("Halftone Threshold", Range(0.3,1)) = 1
        _LightSize("Light Size", Range(0,1)) = 0.5
        _Glossiness("Glossiness", Float) = 32
        _LightSmoothing("Light Smoothing", Range(0,0.1)) = 0.1
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
            float _Threshold;
            sampler2D _HalfToneTex2;
            sampler2D _HalftoneRim;
            float _LightThreshold;
            float4 _MainTex_ST;
            float _ShadeValue;
            float _ShadeIntensity;
            float4 _ObjectColor;
            float _ShadowSize;
            float _LightSize;
            float _Glossiness;
            float _LightSmoothing;
   

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
                fixed screenX = i.screenSpace.x * aspect;
                fixed2 screenUV = fixed2(screenX, i.screenSpace.y) / i.screenSpace.w;

               
                //samples halftones and gets the values via the red channel
                fixed4 halftoneTex = tex2D(_HalfToneTex, screenUV * aspect);
                float halftoneVal = halftoneTex.r;

                fixed4 halftoneTex2 = tex2D(_HalfToneTex2, screenUV);
                float halftone2Val = halftoneTex2.r;
                

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
                float rim = smoothstep(_LightSize - _LightSmoothing, _LightSize + _LightSmoothing, rimLight);
                rim = step(halftoneRimVal, rimLight / _LightThreshold);

                float spotLight = pow(lightDot, _Glossiness * _Glossiness);

                ////specular Lighting
                //float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
                //float halfDot = dot(i.worldNormal, halfVector);
                //float specularIntensity = pow(halfDot + lightDot, _Glossiness * _Glossiness);
                //float specularLight = smoothstep(0.005, 0.01, specularIntensity);
               

                //Draws the halftone shadows
                
                //Below is an attempt at layered shading

                //if(lightDot > _ShadowSize) { 
                //    lightDot = 1;
                //}
                //float halftoneShadow1 = 1;
                //float halftoneShadow2 = 2;
                //if (lightDot < _ShadowSize){
                //    halftoneShadow1 = step(halftoneVal, lightDot);
                //    lightDot = lightDot + halftoneShadow1;
                //}
                //if(lightDot < _ShadowSize/2){
                //    halftoneShadow2 = step(halftone2Val, lightDot);
                //    lightDot = lightDot + halftoneShadow2;
                //}

                if(lightDot > _ShadowSize){
                    lightDot = 1;
                }
                
                //If you don't want the pure blocked shadows, you can use the first the top line
                //lightDot = step(halftoneVal, lightDot / _Threshold);
                lightDot = lightDot > _ShadeValue ? step(halftoneVal, lightDot / _Threshold) : 0;

                //Changes the Shadow Color
                if(lightDot == 0) {
                    lightDot = _ShadeIntensity;
                    
                    col = (_ObjectColor * _ShadeIntensity) + col;  
                }

                return col * (lightDot * _LightColor0  + rim);
            }
            ENDCG
        }

        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
