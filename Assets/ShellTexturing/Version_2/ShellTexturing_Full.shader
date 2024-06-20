Shader "Unlit/ShellTexturing_Full"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _LayerCount ("Layer Count", Integer) = 1
        _LayerHeight ("Layer Height", float) = 0.01
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

            sampler2D _MainTex;
            int _LayerCount;
            float _LayerHeight;

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
                float2 uv : TEXCOORD0;
            };

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

            [maxvertexcount(120)]                                                            // Max output vertices
            void geom (triangle GeomIN input[3], inout TriangleStream<FragIN> triStream)    // Nr input vertices
            {
                // Original verts
                for (int i = 0; i < 3; ++i)
                {
                    FragIN output;
                    output.vertex = UnityObjectToClipPos(input[i].vertex);
                    output.uv = input[i].uv;

                    triStream.Append(output);
                }

                // Layered verts
                for (int i = 0; i < _LayerCount; ++i)
                {
                    for (int v = 0; v < 3; ++v)
                    {
                        FragIN output;
                        output.vertex = input[v].vertex;
                        output.vertex.xyz += input[v].normal * i * _LayerHeight;
                        output.vertex = UnityObjectToClipPos(output.vertex);
                        output.uv = input[v].uv;

                        triStream.Append(output);
                    }
                }
            }

            float4 frag (FragIN input) : SV_Target
            {
               return tex2D(_MainTex, input.uv);
            }
            ENDCG
        }
    }
}
