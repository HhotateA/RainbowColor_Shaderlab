Shader "HOTATE/Wave2Color" {
    Properties {
        _Wave ("wave(nm)",range(390,830)) = 500
    }
    SubShader {
        Tags { "Queue" = "Geometry" "RenderType" = "Opaque"}

        Pass {
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "wave2rgb.cginc"

                float _Wave;

                struct appdata {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD;
                };

                struct v2f {
                    float4 vertex : SV_POSITION;
                    float2 uv : TEXCOORD;
                };

                v2f vert (appdata IN) {
                    v2f output;
                    output.vertex = UnityObjectToClipPos(IN.vertex);
                    output.uv = IN.uv;
                    return output;
                }

                fixed4 frag(v2f IN) : SV_Target {
                    return Wave2RGB(_Wave);
                    //return Val2RGB(IN.uv.x);
                }
            ENDCG
        }
    }
}