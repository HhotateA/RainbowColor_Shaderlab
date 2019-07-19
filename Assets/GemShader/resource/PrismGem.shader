Shader "HOTATE/PrismGeom/Gem" {
    Properties {
        [HDR] _Color ("Color",color) = (1.0,1.0,1.0,1.0)
        _Reaction ("Refractive Index",range(0.0,3.0)) = 1.0
        _Power ("Power", Range(0.0, 100.0)) = 10.0
        _Spectrum ("Spectrum",range(-10.0,10.0)) = 0.0
        _Refrect ("Refrect",range(0.0,10.0)) = 0.0
        _Clampval ("ClampVal",range(0.7,10.0)) = 10.0
        _Wavelength ("BaseWavelength",range(-3000,3000)) = 589.3
        [NoScaleOffset]_MatCap ("Mat Cap", 2D) = "white" {}
        _MatcapColor ("MatcapColor",color) = (1.0,1.0,1.0,0.0)
    }
    SubShader {
        Tags { "Queue" = "Transparent+50"}
        Blend SrcAlpha OneMinusSrcAlpha
        //ZTest always
        //Zwrite off
        CGINCLUDE
            #include "UnityCG.cginc"

            //data on http://cvrl.ucl.ac.uk/cmfs.htm
            static float4 CMF[45]={
                float4(1.50E-03,-4.00E-04,6.20E-03,390.0),
                float4(8.90E-03,-2.50E-03,4.00E-02,400.0),
                float4(3.50E-02,-1.19E-02,1.80E-01,410.0),
                float4(7.02E-02,-2.89E-02,4.67E-01,420.0),
                float4(7.45E-02,-3.49E-02,7.64E-01,430.0),
                float4(3.23E-02,-1.69E-02,9.76E-01,440.0),
                float4(-4.78E-02,2.83E-02,1.00E+00,450.0),
                float4(-1.59E-01,1.08E-01,8.30E-01,460.0),
                float4(-2.85E-01,2.20E-01,6.13E-01,470.0),
                float4(-3.78E-01,3.43E-01,3.50E-01,480.0),
                float4(-4.32E-01,4.72E-01,1.82E-01,490.0),
                float4(-4.35E-01,6.26E-01,9.10E-02,500.0),
                float4(-3.67E-01,7.94E-01,3.57E-02,510.0),
                float4(-1.86E-01,9.48E-01,9.50E-03,520.0),
                float4(1.27E-01,1.02E+00,-4.30E-03,530.0),
                float4(5.36E-01,1.05E+00,-8.20E-03,540.0),
                float4(1.01E+00,1.00E+00,-9.70E-03,550.0),
                float4(1.56E+00,9.16E-01,-9.30E-03,560.0),
                float4(2.15E+00,7.82E-01,-8.00E-03,570.0),
                float4(2.66E+00,5.97E-01,-6.30E-03,580.0),
                float4(3.08E+00,4.20E-01,-4.45E-03,590.0),
                float4(3.17E+00,2.59E-01,-2.77E-03,600.0),
                float4(2.95E+00,1.37E-01,-1.50E-03,610.0),
                float4(2.45E+00,6.11E-02,-6.80E-04,620.0),
                float4(1.84E+00,2.15E-02,-2.72E-04,630.0),
                float4(1.24E+00,4.40E-03,-5.49E-05,640.0),
                float4(7.83E-01,-1.37E-03,2.37E-05,650.0),
                float4(4.44E-01,-2.17E-03,2.61E-05,660.0),
                float4(2.39E-01,-1.64E-03,1.82E-05,670.0),
                float4(1.22E-01,-9.47E-04,1.03E-05,680.0),
                float4(5.86E-02,-4.78E-04,5.22E-06,690.0),
                float4(2.84E-02,-2.35E-04,2.56E-06,700.0),
                float4(1.35E-02,-1.11E-04,1.20E-06,710.0),
                float4(6.38E-03,-5.08E-05,5.55E-07,720.0),
                float4(3.07E-03,-2.34E-05,2.54E-07,730.0),
                float4(1.49E-03,-1.07E-05,1.16E-07,740.0),
                float4(7.39E-04,-4.87E-06,5.31E-08,750.0),
                float4(3.72E-04,-2.22E-06,2.44E-08,760.0),
                float4(1.90E-04,-1.02E-06,1.12E-08,770.0),
                float4(9.84E-05,-4.65E-07,5.07E-09,780.0),
                float4(5.18E-05,-2.08E-07,2.27E-09,790.0),
                float4(2.76E-05,-8.80E-08,9.86E-10,800.0),
                float4(1.49E-05,-3.36E-08,4.07E-10,810.0),
                float4(8.18E-06,-1.09E-08,1.52E-10,820.0),
                float4(4.55E-06,-2.77E-09,4.42E-11,830.0),
            };
        ENDCG

		GrabPass {"_BackgroundTextureBack"}
        Pass {
            Cull front
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment fragFront

                sampler2D _BackgroundTextureBack;
                sampler2D _MatCap;// float4 _MatCap_ST;
                fixed4 _MatcapColor;
                float4 _Color;
                float _Reaction;
                float _Power;
                float _Spectrum;
                float _Refrect;
                float _Clampval;
                float _Wavelength;

                struct appdata {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                };

                struct v2f {
                    float4 screenuv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                    float3 probe : probeUV;
                    float4 refractiveuv : refUV;
                    float2 matcapUV : matcapUV;
                };

                v2f vert (appdata IN) {
                    v2f output;
                    output.vertex = UnityObjectToClipPos(IN.vertex);
                    output.screenuv = ComputeGrabScreenPos(output.vertex);
                    float3 wpos = mul(unity_ObjectToWorld, IN.vertex).xyz;
                    float3 viewdir = normalize(_WorldSpaceCameraPos-wpos);
                    float3 normal = UnityObjectToWorldNormal(IN.normal);
                    float3 viewNormal = mul((float3x3)UNITY_MATRIX_V, normal);
                    output.matcapUV = viewNormal.xy * 0.5 + 0.5;
                    //output.matcapUV = TRANSFORM_TEX(output.matcapUV, _MatCap);
                    normal *= sign(dot(normal,viewdir));
                    output.probe = reflect(-viewdir, normal);
                    float3 refractvec = -refract(viewdir, normal, _Reaction-2.0);
                    float3 samplepos = wpos + refractvec * _Power;
                    float4 screenpos = mul(UNITY_MATRIX_VP, float4(samplepos, 1.0));
                    output.refractiveuv = ComputeGrabScreenPos(screenpos);
                    return output;
                }

                float4 fragFront(v2f IN) : SV_Target {
                    float3 prismcol = (float3)0.0;
                    float4 spectrumvec = IN.refractiveuv - IN.screenuv;
                    float4 sampleuv;
                    for(int index=0;index<45;index++){
                        sampleuv = IN.refractiveuv + (-spectrumvec * _Spectrum * (CMF[index].w-_Wavelength)/450.0);
                        prismcol += tex2Dproj(_BackgroundTextureBack, sampleuv).rgb * CMF[index].rgb;
                    }
                    //prismcol /= 45.0;
                    prismcol /= float3( 4.48E+01, 1.94E+01, 1.09E+01);
                    prismcol *= _Color.rgb;
                    float3 matcapCol = tex2D(_MatCap, IN.matcapUV).rgb*_MatcapColor.rgb;
                    return lerp(float4(clamp(prismcol,0.0,_Clampval),_Color.a),float4(matcapCol.rgb,1.0),_MatcapColor.a);
                }
            ENDCG
        }

		GrabPass {"_BackgroundTextureFront"}
        Pass {
            Cull back
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment fragBack

                sampler2D _BackgroundTextureFront;
                float4 _Color;
                float _Reaction;
                float _Power;
                float _Spectrum;
                float _Refrect;
                float _Clampval;
                float _Wavelength;

                struct appdata {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                };

                struct v2f {
                    float4 screenuv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                    float3 probe : probeUV;
                    float4 refractiveuv : refUV;
                    float rim : rimLev;
                };

                v2f vert (appdata IN) {
                    v2f output;
                    output.vertex = UnityObjectToClipPos(IN.vertex);
                    output.screenuv = ComputeGrabScreenPos(output.vertex);
                    float3 wpos = mul(unity_ObjectToWorld, IN.vertex).xyz;
                    float3 viewdir = normalize(_WorldSpaceCameraPos-wpos);
                    float3 normal = UnityObjectToWorldNormal(IN.normal);
                    normal *= sign(dot(normal,viewdir));
                    output.probe = reflect(-viewdir, normal);
                    float3 refractvec = refract(viewdir, normal, _Reaction-2.0);
                    float3 samplepos = wpos + refractvec * _Power;
                    float4 screenpos = mul(UNITY_MATRIX_VP, float4(samplepos, 1.0));
                    output.refractiveuv = ComputeGrabScreenPos(screenpos);
                    output.rim = lerp(1.0,dot(viewdir,normal),step(0.0,dot(normal,viewdir)));
                    return output;
                }

                float4 fragBack(v2f IN) : SV_Target {
                    float3 prismcol = (float3)0.0;
                    float4 spectrumvec = IN.refractiveuv - IN.screenuv;
                    float4 sampleuv;
                    for(int index=0;index<45;index++){
                        sampleuv = IN.refractiveuv + (spectrumvec * _Spectrum * (CMF[index].w-_Wavelength)/450.0);
                        prismcol += tex2Dproj(_BackgroundTextureFront, sampleuv).rgb * CMF[index].rgb;
                    }
                    //prismcol /= 45.0;
                    prismcol /= float3( 4.48E+01, 1.94E+01, 1.09E+01);
                    prismcol *= _Color.rgb;
                    float4 skydata = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, IN.probe);
                    float3 skycol = DecodeHDR (skydata, unity_SpecCube0_HDR);
                    float weight = pow(IN.rim,_Refrect);
                    float3 col = lerp( skycol, prismcol, weight);
                    //float3 col = tex2Dproj(_BackgroundTextureFront, IN.screenuv).rgb;
                    return float4(clamp(col,0.0,_Clampval),_Color.a);
                }
            ENDCG
        }
    }
}