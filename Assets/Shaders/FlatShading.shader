Shader "Unlit/FlatShading"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ObjectColor("Object Color", Color) = (1,1,1,1)
        _ShadowColor("Shadow Color", Color) = (1,1,1,1)
        _ShadowIntensity("Shadow Level", Range(0,1)) = 0.5
        _LightSize("Light Size", Range(0,1)) = 0.5

        _ShadeValue1("Shade Value 1", Range(0,1)) = 0.15
        _ShadeValue2("Shade Value 2", Range(0,1)) = 0.35
        _ShadeValue3("Shade Value 3", Range(0,1)) = 0.55

        _Glossiness("Glossiness", Float) = 32
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 100

         Pass{

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

        
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION; 
                float2 uv : TEXCOORD0;
                half3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 worldNormal : NORMAL;
                float3 viewDir : TEXCOORD1;
                half3 normal : TEXCOORD2;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _ObjectColor;
            float4 _ShadowColor;
            float _ShadowIntensity;
            float _LightSize;

            float _ShadeValue1;
            float _ShadeValue2;
            float _ShadeValue3;

            float _Glossiness;

             v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                o.normal = v.normal;
   
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               fixed4 col = tex2D(_MainTex, i.uv);

                return col;
            }
            ENDCG



        }
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
                float3 viewDir : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _ObjectColor;
            float4 _ShadowColor;
            float _ShadowIntensity;
            float _LightSize;

            float _ShadeValue1;
            float _ShadeValue2;
            float _ShadeValue3;

            float _Glossiness;
                      

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = WorldSpaceViewDir(v.vertex);
  
                TRANSFER_SHADOW(o);
      
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 viewDir = normalize(i.viewDir);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float shadow = SHADOW_ATTENUATION(i);
             

               

                //calculates how shadow is perceived
                //shadow is added to the dotted light values 
                float lightDot = dot(i.worldNormal, lightDir) * shadow;
                float shade;
                if(lightDot >_ShadeValue3){
                    shade = 1;
                } else if(lightDot > _ShadeValue2 && lightDot < _ShadeValue3){
                    shade = _ShadowIntensity + 0.2 ;
                } else if( lightDot > _ShadeValue1 && lightDot < _ShadeValue2){
                    shade = _ShadowIntensity + 0.1 ;
                } else if (lightDot < _ShadeValue1){
                    shade = _ShadowIntensity ;
                }

                //calculates the rimlighting
                float viewDot = 1 - dot(normalize(i.viewDir), i.worldNormal);
                float rimLight = viewDot * lightDot;
                float rim = smoothstep(_LightSize - 0.01, _LightSize + 0.01, rimLight);


                float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
                float NdotH = dot(i.worldNormal, halfVector);

                float specularIntensity = pow(NdotH * lightDot, _Glossiness * _Glossiness);
                float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity);
                float4 specular = specularIntensitySmooth * _LightColor0;


                return col * (shade *_LightColor0 + rim);
            }
            ENDCG
        }
       
        //ShadowCasting Support
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
