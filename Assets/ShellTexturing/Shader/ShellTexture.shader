Shader "Unlit/ShellTexture"
{
    Properties
    {
        _Density("Density", int) = 256
    }
    SubShader
    {
        Pass
        {
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
                float2 uv : TEXCOORD0;
            };

            struct VertexOUT
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            ////////////////////////////////////////////////////////////
            // ---------------------------------------------------------
            ////////////////////////////////////////////////////////////

            int _Density;

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

            VertexOUT vert (VertexIN v)
            {
                VertexOUT o;

                // Transform
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            fixed4 frag (VertexOUT i) : SV_Target
            {
                // Get random value
                uint2 convertedUV = i.uv * _Density;
                uint seed = convertedUV.x + convertedUV.y * _Density;
                bool isValid = 0.5 < Hash(seed);

                // Set color
                fixed4 col = isValid ? fixed4(1, 1, 1, 1) : fixed4(0, 0, 0, 1);
                return col;
            }

            ENDCG
        }
    }
}
