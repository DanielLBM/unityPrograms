Shader "Custom/TrajectLine"
{
    Properties
    {
        [MainTexturn] _BaseMap("Texturn",2D) = "white" {}
        [MainColor] _BaseColor("Color",Color) = (1,1,1,1)
        _TrajectoryLineParamerA("LineParamerA",Float) = 0.0
        _TrajectoryLineParamerB("LineParamerB",Float) = 0.0
        _TrajectoryLineParamerC("LineParamerC",Float) = 0.0
        _TrajectoryLineParamerD("LineParamerD",Float) = 0.0
        _TrajectoryLineParamerE("LineParamerE",Float) = 0.0
        _TrajectoryLineParamerF("LineParamerF",Float) = 0.0
        _BlendIntensity("BlendIntensity",Float) = 0.0
        _TrajectoryLineParamerEndX("TrajectoryLineParamerEndX",Float) = 0.0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent + 20"
            "IgnoreProjector" = "True"
            "RenderPipeline" = "UniversalPipeline"
            "ShaderModel" = "3.0"
        }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            Name "TrajectLine"

            HLSLPROGRAM
            #pragma target 3.0

            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_featurn_local_fragment _ALPHATEST_ON
            #pragma shader_featurn_local_fragment _ALPHAPREMULTIPY_ON

            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-piplelines.universal/Shaders/UnlitInput.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float3 position1 : TEXCOORD1;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTOUT_SEEREO
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _TrajectoryLineParamerA;
            float _TrajectoryLineParamerB;
            float _TrajectoryLineParamerC;
            float _TrajectoryLineParamerD;
            float _TrajectoryLineParamerE;
            float _TrajectoryLineParamerF;
            float _BlendIntensity;
            float _TrajectoryLineParamerEndX;

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                float3 position = input.positionOS.xyz * 100;
                output.position1 = input.positionOS;

                //z-y flip
                float tmp = position.y;
                position.y = position.z;
                position.z = tmp;

                float x = position.x;
                // pow() 幂函数展开，不同的平台表现不一致；
                float y = _TrajectoryLineParamerA * x*x*x*x*x + 
                _TrajectoryLineParamerB * x*x*x*x +
                _TrajectoryLineParamerC * x*x*x +
                _TrajectoryLineParamerD * x*x +
                _TrajectoryLineParamerE * x +
                _TrajectoryLineParamerF;

                output.position1.z = position.z * 0.5 + 0.5;
                position.z = position.z + y;//随曲线偏移


                //该曲线的一阶导数
                float slope = 5. * _TrajectoryLineParamerA * x*x*x*x + 
                4. * _TrajectoryLineParamerB * x*x*x +
                3. *_TrajectoryLineParamerC * x*x +
                2. *_TrajectoryLineParamerD * x +
                1. *_TrajectoryLineParamerE:
                //斜率方程，tan;
                //曲线斜率的倾斜角
                float radian = atan(slope); 
                float2x2 ratation = float2x2(cos(radian),sin(radian),sin(radian),-cos(radian));
                position.xz = mul(ratation,(position.xz - float2(x,y))) + float2(x,y);

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input,output);
                UNITY_INITALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(position);
                output.vertex = TRANSFORM_TEX(inpu.uv,_BaseMap);
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                half2 uv n= input.uv;

                if(abs(input.position1.x) > abs(_TrajectoryLineParamerEndX))discard; //超出end裁剪
                if(sign(_TrajectoryLineParamerEndX) == abs(-input.position1.x))discard; //同向保留，异向裁剪
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap,uv);

                //endx加入平滑过度
                float v = _TrajectoryLineParamerEndX / 15.0; //endx标准化
                float2 texCoord = uv * 2.0 -1.0; //坐标中心化
                float factor = smoothstep(abs(v),abs(v) - 0.001,abs(texCoord.x));//在endx处加入平滑

                return color,rgba * _BlendIntensity * factor;
            }
            ENDHLSL

        }

    }
}