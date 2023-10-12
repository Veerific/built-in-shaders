Shader "Unlit/FlatShading"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ObjectColor("Object Color", Color) = (1,1,1,1)
        _ShadowColor("Shadow Color", Color) = (1,1,1,1)
        _LightColor("Light Color", Color) = (1,1,1,1)
        _ShadowIntensity("Shadow Level", Range(0,1)) = 0.5
        _LightSize("Light Size", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" 
        
        }
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : NORMAL;
                float3 viewDir : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _ObjectColor;
            float4 _LightColor;
            float4 _ShadowColor;
            float _ShadowIntensity;
            float _LightSize;
           

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = WorldSpaceViewDir(v.vertex);
      
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 viewDir = normalize(i.viewDir);
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                float lightDot = dot(i.worldNormal, lightDir);
                float lightIntensity = lightDot > 0 ? 1 : _ShadowIntensity;

                float viewDot = 1 - dot(normalize(i.viewDir), i.worldNormal);
                float rimLight = viewDot * lightDot;
                float rim = smoothstep(_LightSize - 0.01, _LightSize + 0.01, rimLight);

   
                return _ObjectColor * (lightIntensity + rim);
            }
            ENDCG
        }
    }
}
