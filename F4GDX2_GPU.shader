Shader "Astrah_Graphics/F4GDX2_GPU"
{
    Properties
    {
        _ScaleFactor("Scale Factor", Float) = 0.5
        _BlendThreshold("Blend Threshold", Float) = 0.5
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo Map", 2D) = "black" {}
        _MetallicGlossMap("Metallic (R) Smoothness (A) Map", 2D) = "black" {}
        _Hue("Hue", Float) = 1.0
        _Contrast("Contrast", Float) = 1.0
        _Saturation("Saturation", Float) = 1.0
        _Brightness("Brightness", Float) = 1.0
        _Cutoff("Alpha cutoff", Range(0,1)) = 0.5
        _BlendCutoff("Alpha Blend Cutoff", Range(0,1)) = 0.1
        _MainTex_TexelSize("MainTex Texel Size", Vector) = (1.0, 1.0, 1.0, 1.0)
    }


        Subshader
        {

            Tags {"Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout"}
            LOD 200

            Stencil {
                Ref 1
                Comp notequal
                Pass keep
            }

            CGPROGRAM
            #pragma surface SurfaceShader Standard Lambert alphatest:_Cutoff fullforwardshadows addshadow

            sampler2D _MainTex, _MetallicGlossMap;
            sampler2D _MainTex_Constant;
            float4 _MainTex_TexelSize;
            float4 _Color;
            float _Hue, _Contrast, _Saturation;
            float _Brightness;
            float _ScaleFactor;
            float _BlendThreshold;
            float _BlendCutoff;


            struct Input
            {
                float2 uv_MainTex               : TEXCOORD0;
                float2 uv_MetallicGlossMap      : TEXCOORD1;
            };

            float3 RGBToHSV(float3 c)
            {
                float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
                float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
                float d = q.x - min(q.w, q.y);
                float e = 1.0e-10;
                return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }

            float4x4 contrastMatrix(float c) {
                float t = (1.0 - c) * 0.5;
                return float4x4 (
                    c, 0, 0, 0,
                    0, c, 0, 0,
                    0, 0, c, 0,
                    t, t, t, 1
                    );
            }

            float3 HSVToRGB(float3 c) {
                float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
            }

            float GetColorWeight(float4 color)
            {
                float3 rgb = color.rgb;
                float a = color.a;

                // Calculate color weight based on the RGB components
                float maxComponent = max(max(rgb.r, rgb.g), rgb.b);
                float sumComponents = rgb.r + rgb.g + rgb.b;
                float weight = (maxComponent + sumComponents * 0.5) / (sumComponents + 0.5);

                // Apply alpha component to the color weight
                weight *= a;

                return weight;
            }

            bool isHeavy(float colorWeight) {
                float weightThreshold = 0.85;

                if (colorWeight < weightThreshold) {
                    return true;
                }
                 else {
                  return false;
                }
                }

                bool ColorsAreEqual(float4 colorA, float4 colorB)
                {
                    return colorA.rgb == colorB.rgb && colorA.a == colorB.a;
                }

                bool ColorsAreClose(float3 color1, float3 color2)
                {
                    float3 colorDiff = color1 - color2;
                    float distance = length(colorDiff);
                    return distance <= _BlendThreshold;
                }



            void SurfaceShader(Input IN, inout SurfaceOutputStandard o)
            {

                float texelSize_width = _MainTex_TexelSize.z;     // contains width
                float texelSize_height = _MainTex_TexelSize.w;     // contains height
                float texelX = IN.uv_MainTex.x * texelSize_width * _ScaleFactor;
                float texelY = IN.uv_MainTex.y * texelSize_height * _ScaleFactor;

                float offsetFactor = _MainTex_TexelSize / 2;

                //float4 color_A       = tex2D(_MainTex,    IN.uv_MainTex + float2(-2.0, -2.0)       * _MainTex_TexelSize * _ScaleFactor);
                float4 color_B = tex2D(_MainTex,    IN.uv_MainTex + float2(-1.0, -2.0) * _MainTex_TexelSize * _ScaleFactor);
                float4 color_C = tex2D(_MainTex,      IN.uv_MainTex + float2(0.0, -2.0) * _MainTex_TexelSize * _ScaleFactor);
                float4 color_D = tex2D(_MainTex,    IN.uv_MainTex + float2(1.0, -2.0) * _MainTex_TexelSize * _ScaleFactor);
                //float4 color_E       = tex2D(_MainTex,    IN.uv_MainTex + float2(2.0, -2.0)         * _MainTex_TexelSize * _ScaleFactor);

                float4 color_F = tex2D(_MainTex,    IN.uv_MainTex + float2(-2.0, -1.0) * _MainTex_TexelSize * _ScaleFactor);
                float4 color_G = tex2D(_MainTex,      IN.uv_MainTex + float2(-1.0, -1.0) * _MainTex_TexelSize * _ScaleFactor);
                float4 color_H = tex2D(_MainTex,      IN.uv_MainTex + float2(0.0, -1.0) * _MainTex_TexelSize * _ScaleFactor);
                float4 color_I = tex2D(_MainTex,      IN.uv_MainTex + float2(1.0, -1.0) * _MainTex_TexelSize * _ScaleFactor);
                float4 color_J = tex2D(_MainTex,    IN.uv_MainTex + float2(2.0, -1.0) * _MainTex_TexelSize * _ScaleFactor);

                float4 color_K = tex2D(_MainTex,      IN.uv_MainTex + float2(-2.0, 0.0) * _MainTex_TexelSize * _ScaleFactor);
                float4 color_L = tex2D(_MainTex,      IN.uv_MainTex + float2(-1.0, 0.0) * _MainTex_TexelSize * _ScaleFactor);
                float4 color_Center = tex2D(_MainTex,      IN.uv_MainTex + float2(0.0, 0.0) * _MainTex_TexelSize * _ScaleFactor);
                float4 color_N = tex2D(_MainTex,      IN.uv_MainTex + float2(1.0, 0.0) * _MainTex_TexelSize * _ScaleFactor);
                float4 color_O = tex2D(_MainTex,      IN.uv_MainTex + float2(2.0, 0.0) * _MainTex_TexelSize * _ScaleFactor);

                float4 color_P = tex2D(_MainTex,    IN.uv_MainTex + float2(-2.0, 1.0) * _MainTex_TexelSize * _ScaleFactor);
                float4 color_Q = tex2D(_MainTex,      IN.uv_MainTex + float2(-1.0, 1.0) * _MainTex_TexelSize * _ScaleFactor);
                float4 color_R = tex2D(_MainTex,      IN.uv_MainTex + float2(0.0, 1.0) * _MainTex_TexelSize * _ScaleFactor);
                float4 color_S = tex2D(_MainTex,      IN.uv_MainTex + float2(1.0, 1.0) * _MainTex_TexelSize * _ScaleFactor);
                float4 color_T = tex2D(_MainTex,    IN.uv_MainTex + float2(2.0, 1.0) * _MainTex_TexelSize * _ScaleFactor);

                //float4 color_U       = tex2D(_MainTex,    IN.uv_MainTex + float2(-2.0, 2.0)         * _MainTex_TexelSize * _ScaleFactor);
                float4 color_V = tex2D(_MainTex,    IN.uv_MainTex + float2(-1.0, 2.0) * _MainTex_TexelSize * _ScaleFactor);
                float4 color_W = tex2D(_MainTex,      IN.uv_MainTex + float2(0.0, 2.0) * _MainTex_TexelSize * _ScaleFactor);
                float4 color_X = tex2D(_MainTex,    IN.uv_MainTex + float2(1.0, 2.0) * _MainTex_TexelSize * _ScaleFactor);
                //float4 color_Y       = tex2D(_MainTex,    IN.uv_MainTex + float2(2.0, 2.0)         * _MainTex_TexelSize * _ScaleFactor);

                //Diaganol Lines:
                float lerpValue = 1.0;
                if (ColorsAreEqual(color_B,color_H) && ColorsAreEqual(color_H,color_N) && ColorsAreEqual(color_N,color_T)) {
                    color_Center = color_H;
                }
                else if (ColorsAreEqual(color_X,color_R) && ColorsAreEqual(color_R,color_L) && ColorsAreEqual(color_L,color_F)) {
                    color_Center = color_R;
                }
                else if (ColorsAreEqual(color_J,color_N) && ColorsAreEqual(color_N,color_R) && ColorsAreEqual(color_R,color_V)) {
                    color_Center = color_N;
                }
                else if (ColorsAreEqual(color_D,color_H) && ColorsAreEqual(color_H,color_L) && ColorsAreEqual(color_L,color_P)) {
                    color_Center = color_H;
                }

                // - Brightness
                color_Center.rgb            = color_Center.rgb * _Brightness;

                // - Hue, Saturation
                float3 hsv                  = RGBToHSV(color_Center.rgb);
                hsv.x                       *= _Hue;
                hsv.y                       *= _Saturation;
                color_Center.rgb            = HSVToRGB(hsv);

                // - Contrast
                color_Center.rgb = mul(float4(color_Center.rgb,1.0), contrastMatrix(_Contrast)).rgb;

                o.Metallic      = tex2D(_MetallicGlossMap, IN.uv_MetallicGlossMap).r;
                o.Smoothness    = tex2D(_MetallicGlossMap, IN.uv_MetallicGlossMap).a;

                o.Albedo = color_Center;
                o.Alpha = color_Center.a;

            }

        ENDCG

        }

}
