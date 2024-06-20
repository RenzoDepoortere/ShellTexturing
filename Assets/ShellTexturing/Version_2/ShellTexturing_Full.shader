Shader "Unlit/ShellTexturing_Full"
{
    Properties
    {
        _TextureMap ("Texture Map", 2D) = "white" {}
        _HeightMap ("Height Map", 2D) = "white" {}

        _TopHairColor ("Top Hair Color", Color) = (1, 1, 1, 1)
        _BotHairColor ("Bot Hair Color", Color) = (0, 0, 0, 1)
        _FillBottom ("Fill Bottom", Integer) = 1

        _Density ("Density", Integer) = 256
        _LayerCount ("Layer Count", Integer) = 1
        _FullHeight ("FullHeight", float) = 0.5

        _Thickness ("Thickness", float) = 1
        _MinSeedRange ("Min Seed Range", float) = 0.1
        _MaxSeedRange ("Max Seed Range", float) = 0.8
    }
    SubShader
    {
        Pass
        {
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityPBSLighting.cginc"

            ////////////////////////////////////////////////////////////
            // ---------------------------------------------------------
            ////////////////////////////////////////////////////////////

            sampler2D _TextureMap;
            sampler2D _HeightMap;

            float4 _TopHairColor;
            float4 _BotHairColor;
            int _FillBottom;

            int _Density;
            int _LayerCount;
            float _FullHeight;

            float _Thickness;
            float _MinSeedRange;
            float _MaxSeedRange;

            ////////////////////////////////////////////////////////////
            // ---------------------------------------------------------
            ////////////////////////////////////////////////////////////

            struct VertexIN
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            struct GeomIN
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            struct FragIN
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                int layerIdx : ID;
            };

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

            float HalfLambert(float3 normal)
            {
                float halfLambert = DotClamped(normal, _WorldSpaceLightPos0) * 0.5 + 0.5;     // DotClamped for making shadows even softer
                return halfLambert * halfLambert;
            }

            ////////////////////////////////////////////////////////////
            // ---------------------------------------------------------
            ////////////////////////////////////////////////////////////

            GeomIN vert (VertexIN input)
            {
                GeomIN o;

                o.vertex = input.vertex;
                o.normal = input.normal;
                o.uv = input.uv;

                return o;
            }

            [maxvertexcount(90)]                                                            // Max output vertices
            void geom (triangle GeomIN input[3], inout TriangleStream<FragIN> triStream)    // Nr input vertices
            {
                // Original verts
                for (int i = 0; i < 3; ++i)
                {
                    FragIN output;
                    output.vertex = UnityObjectToClipPos(input[i].vertex);
                    output.normal = input[i].normal;
                    output.uv = input[i].uv;
                    output.layerIdx = 0;

                    triStream.Append(output);
                }

                // Layered verts
                // -------------
                float deltaHeight = _FullHeight / _LayerCount;

                for (int i = 0; i < _LayerCount; ++i)
                {
                    for (int v = 0; v < 3; ++v)
                    {
                        // Position
                        FragIN output;
                        output.vertex = input[v].vertex;
                        output.vertex.xyz += input[v].normal * i * deltaHeight;
                        output.vertex = UnityObjectToClipPos(output.vertex);

                        // Other
                        output.normal = input[v].normal;
                        output.uv = input[v].uv;
                        output.layerIdx = i + 1;

                        // Append
                        triStream.Append(output);
                    }
                }
            }

            float4 frag (FragIN input) : SV_Target
            {
                // Check for bottomLayer
                // ---------------------
                
                float4 textureColor = tex2D(_TextureMap, input.uv);
                if (1 <= _FillBottom && input.layerIdx == 0)
                    return _BotHairColor * textureColor;

                // Get values
                // ----------

                // Calculate distance from center
                float2 convertedUV = input.uv * _Density;
                float2 localPos = frac(convertedUV) * 2 - 1;
                float distanceFromCenter = length(localPos);

                // Sample Map
                float4 heightColor = tex2D(_HeightMap, input.uv);

                // Get random value
                uint2 seedUV = convertedUV;
                uint seed = seedUV.x + seedUV.y * _Density;
                float randomValue = Hash(seed) * heightColor.r;

                // Height & Thickness
                // ------------------

                // Get shellHeight
                float lerpValue = (float) input.layerIdx / _LayerCount;
                float shellHeight = lerp(_MinSeedRange, _MaxSeedRange, lerpValue);

                // Check if valid height
                bool isValid = shellHeight < randomValue;
                if (!isValid) discard;

                // Check if valid thickness
                float thicknessOffset = lerp(_MinSeedRange, _MaxSeedRange, randomValue);

                bool isValidThickness = distanceFromCenter < _Thickness * (thicknessOffset - lerpValue);
                if (!isValidThickness) discard;


                // Calculate finalColor
                // --------------------

                float4 lerpedColor = lerp(_BotHairColor, _TopHairColor, lerpValue);    // Lerp between bottom and top
                float4 finalColor = lerpedColor * textureColor * HalfLambert(input.normal);

                return finalColor;
            }
            ENDCG
        }
    }
}
