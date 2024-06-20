Shader "Unlit/ShellTexture"
{
    SubShader
    {
        Pass
        {
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityPBSLighting.cginc"

            ////////////////////////////////////////////////////////////
            // ---------------------------------------------------------
            ////////////////////////////////////////////////////////////

            struct VertexIN
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct FragIN
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            ////////////////////////////////////////////////////////////
            // ---------------------------------------------------------
            ////////////////////////////////////////////////////////////

            int _NrShells;
            int _ShellIdx;

            float4 _TextureColor;
            int _Density;
            float _FullHeight;
            float _Thickness;
            float _MinSeedRange, _MaxSeedRange;

            ////////////////////////////////////////////////////////////
            // ---------------------------------------------------------
            ////////////////////////////////////////////////////////////

            float Hash(uint n)
            {
	            // Integer hash copied from Hugo Elias -> (I got it from Acerola)
                n = (n << 13U) ^ n;
                n = n * (n * n * 15731U + 0x789221U) + 0x1376312589U;
                return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
            }

            ////////////////////////////////////////////////////////////
            // ---------------------------------------------------------
            ////////////////////////////////////////////////////////////

            FragIN vert (VertexIN v)
            {
                FragIN o;

                // Offset vertexPosition along normal
                float4 vertexPosition = v.vertex;

                if (0 < _NrShells)
                {
                    float deltaHeight = _FullHeight / _NrShells;
                    vertexPosition.xyz += _ShellIdx * deltaHeight * v.normal;
                }

                o.vertex =  UnityObjectToClipPos(vertexPosition);
                
                // Pass values
                o.normal = v.normal;
                o.uv = v.uv;

                return o;
            }

            float4 frag (FragIN i) : SV_Target
            {
                // Get values
                // ----------

                // Calculate distance from center
                float2 convertedUV = i.uv * _Density;
                float2 localPos = frac(convertedUV) * 2 - 1;
                float distanceFromCenter = length(localPos);

                // Get random value
                uint2 seedUV = convertedUV;
                uint seed = seedUV.x + seedUV.y * _Density;
                float randomValue = Hash(seed);

                // Height & Thickness
                // ------------------

                // Check if valid pixel
                float lerpValue = (float) _ShellIdx / _NrShells;
                float shellHeight = lerp(_MinSeedRange, _MaxSeedRange, lerpValue);

                bool isValid = shellHeight < randomValue;
                if(!isValid) discard;

                // Check if valid thickness
                float thicknessOffset = lerp(_MinSeedRange, _MaxSeedRange, randomValue);

                bool isValidThickness = distanceFromCenter < _Thickness * (thicknessOffset - lerpValue);
                if (!isValidThickness) discard;


                // Calculate finalColor
                // --------------------
                float4 defaultHairColor = _TextureColor /* * lerpValue */;                      // LerpValue for making hair darker near bottom
                float halfLambert = DotClamped(i.normal, _WorldSpaceLightPos0) * 0.5 + 0.5;     // DotClamped for making shadows even softer

                float4 finalColor = defaultHairColor * (halfLambert * halfLambert);
                finalColor.a = 1;
                return finalColor;
            }

            ENDCG
        }
    }
}
