Shader "Unlit/ShellTexture"
{
    Properties
    {
        _Density("Density", int) = 256
        _ShellHeight("Shell Height", float) = 1.0
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

            int _Density;
            float _ShellHeight;

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

                // Transform
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                o.uv = v.uv;

                return o;
            }

            [maxvertexcount(6)]                                                                 // Max 6 vertices as input (you can append less than this amount)
            void geom(triangle GeometryIN input[3], inout TriangleStream<FragIN> triStream)     // 3 vertices received as parameter -> triangle
            {
                // Original vertex
                // ---------------
                for (int i = 0; i < 3; ++i)
                {
                    FragIN output;
                    
                    // Pass values
                    output.vertex = input[i].vertex;
                    output.normal = input[i].normal;
                    output.uv = input[i].uv;
                    
                    // Append
                    triStream.Append(output);
                }

                // Extra vertex
                // ------------
                for (int i = 0; i < 3; ++i)
                {
                     FragIN output;

                    // Transform vertex height
                    float4 startPos = input[i].vertex;
                    startPos.xyz += input[i].normal * _ShellHeight;
                    output.vertex = startPos;
                    
                    // Pass values
                    output.normal = input[i].normal;
                    output.uv = input[i].uv;

                    // Append
                    triStream.Append(output);
                }
            }

            fixed4 frag (FragIN i) : SV_Target
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
