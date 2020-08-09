Shader "Custom/DepthFade"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _EdgeColor("EdgeColor", Color) = (1, 1, 1, 1)
        _DepthFactor("Depth Factor", float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
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
                float4 screenPos : TEXCOORD1;
            };

            uniform sampler2D _CameraDepthTexture;
            fixed4 _Color; 
            fixed4 _EdgeColor; 
            float _DepthFactor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos));
                half depth = LinearEyeDepth(depthSample);
                half screenDepth = depth - i.screenPos.w;
                float foamLine = 1 - saturate(_DepthFactor * screenDepth);
                fixed4 col = lerp(_Color, _EdgeColor, foamLine);
                // fixed4 col = _Color + foamLine * _EdgeColor;   //if you need EdgeColor as Emission.
                return col;
            }
            ENDCG
        }
    }
}
