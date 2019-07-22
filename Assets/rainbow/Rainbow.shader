Shader "HOTATE/Rainbow" {
    Properties {
        _Ypow ("Y曲げ具合",range(0.0,5000.0)) = 1000.0
        _Xpow ("X曲げ具合",range(0.0,5000.0)) = 100.0
        _Height ("高さ",range(-5000,5000)) = 0.0
        _Brightnes ("明るさ",range(0,30)) = 1.0
    }
    SubShader {
        Tags { "Queue" = "Transparent"}
        Blend One One

        Pass {
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "wave2rgb.cginc"

                float _Ypow, _Xpow, _Height, _Brightnes;

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
                    return Wave2RGB(IN.uv.y*_Ypow + (IN.uv.x-0.5)*(IN.uv.x-0.5)*_Xpow + _Height) * _Brightnes;
                }
            ENDCG
        }
    }
}