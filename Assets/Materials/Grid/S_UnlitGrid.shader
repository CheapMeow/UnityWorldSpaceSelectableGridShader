Shader "Unlit/UnlitGrid"
{
    Properties
    {
        [PerRendererData] _MainTex ("Texture", 2D) = "white" {}
        _GridCellSize ("Grid Cell Size", float) = 1
        [FloatRange] _GridLineSize ("Grid Line Size", Range(0,1)) = 0.02
        _LineColor ("Line Color", Color) = (0.7, 0.7, 0.7, 1)
        _ReachableTint ("Reachable Tint", Color) = (0.9, 0.9, 0.9, 1)
        _UnreachableTint ("Unreachable Tint", Color) = (0.6, 0.6, 0.6, 1)    
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 worldSpacePos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _GridCellSize;
            float _GridLineSize;
            float4 _LineColor;
            float4 _ReachableTint;
            float4 _UnreachableTint;
            
            uniform float4 click_pos;
            uniform float should_tint;
            uniform float tint_radius;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);

                o.worldSpacePos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            fixed4 add_tint(fixed4 col, float2 ipos)
            {
                float2 ipos_relatived_to_click_ipos = ipos - floor(click_pos/_GridCellSize);
                
                float dist = ipos_relatived_to_click_ipos.x * ipos_relatived_to_click_ipos.x
                            + ipos_relatived_to_click_ipos.y * ipos_relatived_to_click_ipos.y;
                
                float reachable = step(dist, tint_radius * tint_radius + 0.001);
                
                fixed4 tint = col * _UnreachableTint * (1.0 - reachable) + col * _ReachableTint * reachable;
                
                col = col * (1.0 - should_tint) + tint * should_tint;

                return col;
            }
            
            fixed4 add_grid(fixed4 col, float2 fpos)
            {
                float scaled_line_size = _GridLineSize/_GridCellSize;
                
                float2 bl = step(float2(scaled_line_size, scaled_line_size), fpos);       // bottom-left
                float2 tr = step(float2(scaled_line_size, scaled_line_size), float2(1.0, 1.0) - fpos);   // top-right
                float grid_brightness = 1.0 - bl.x * bl.y * tr.x * tr.y;

                col = col * (1.0 - grid_brightness) + _LineColor * grid_brightness;

                return col;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float2 st = i.worldSpacePos.xy / _GridCellSize;

                float2 ipos = floor(st);  // integer
                float2 fpos = frac(st);  // fraction

                fixed4 col = tex2D(_MainTex, i.uv);

                col = add_tint(col, ipos);
                col = add_grid(col, fpos);
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}