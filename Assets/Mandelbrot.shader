Shader "Puru/Mandelbrot"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Area("Area", vector) = (0, 0, 4, 4)
        _Angle("Angle", range(-3.1415, 3.1415)) = 0
        _MaxIter("MaxIter", range(4, 1000)) = 255
        _Color("Color", range(0, 1)) = 0.5
        _Repeat("Repeat", float) = 1
        _Speed("Speed", float) = 1
        _Symmetry("Symmetry", range(0, 1)) = 0
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 _Area;
            float _Angle;
            float _MaxIter;
            float _Color;
            float _Repeat;
            float _Speed;
            int _Symmetry;
            sampler2D _MainTex;

            float2 RotatePoint(float2 p, float2 pivot, float a)
            {
            	float s = sin(a);
            	float c = cos(a);
            	p -= pivot;
            	p = float2(p.x*c - p.y*s, p.x*s + p.y*c);
            	p += pivot;

            	return p;
            }

            fixed4 frag (v2f i) : SV_Target
            {
            	float2 uv = (i.uv-0.5);
            	uv = abs(uv);
            	uv = RotatePoint(uv, 0, 3.1415*0.125);
            	uv = abs(uv);

            	uv = lerp((i.uv-0.5), uv, _Symmetry);

                float2 c = _Area.xy + uv*_Area.zw;
                c = RotatePoint(c, _Area.xy, _Angle);

                float r = 20; //escape radius
                float r2 = r*r;
                float2 z, zPrev;

                float iter;
                for (iter = 0; iter < _MaxIter; iter++)
                {
                	//zPrev = z;
                	zPrev = RotatePoint(z, 0, _Time.y);
                	z = float2(z.x * z.x - z.y * z.y, 2 * z.x * z.y) + c;
                	if (dot(z, zPrev) > r2)
                	{
                		break;
                	}
                }

                if (iter >= _MaxIter)
                {
                	return 0;
                }

                float dist = length(z); //dist from origin
                //float fracIter = (dist - r)/(r2-r); //linear interpolation
                float fracIter = log2(log(dist) / log(r)); //exponential interpolation

                //iter -= fracIter;
                float m = sqrt(iter/_MaxIter);
                float4 col = sin(float4(0.3, 0.45, 0.65, 1)*m*20)*0.5 + 0.5f; 
                col = tex2D(_MainTex, float2(m*_Repeat + _Time.y*_Speed, _Color));

                col *= smoothstep(3, 0, fracIter);

                //for waves on leafs
                float angleWithOrigin = atan2(z.x, z.y);
                col *= 1 + sin(angleWithOrigin*2 + _Time.y*4)*0.2;

                return col;
            }
            ENDCG
        }
    }
}
