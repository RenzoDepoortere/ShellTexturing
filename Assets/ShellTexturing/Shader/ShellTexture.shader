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

             ////////////////////////////////////////////////////////////
            // ---------------------------------------------------------
            ////////////////////////////////////////////////////////////

            struct VertexIN
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct GeometryIN
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

            int _Density;
            float _FullHeight;
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

            GeometryIN vert (VertexIN v)
            {
                GeometryIN o;

                // Offset vertexPosition
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

            fixed4 frag (FragIN i) : SV_Target
            {
                // Get random value
                uint2 convertedUV = i.uv * _Density;
                uint seed = convertedUV.x + convertedUV.y * _Density;

                // Check if valid pixel
                float lerpValue = (float) _ShellIdx / _NrShells;
                float minValue = lerp(_MinSeedRange, _MaxSeedRange, lerpValue);
                bool isValid = minValue < Hash(seed);
                if(!isValid) discard;

                // Set color
                fixed4 textureColor = fixed4(1, 1, 1, 1);
                textureColor *= lerpValue;
                return textureColor;
            }

            ENDCG
        }
    }
}
