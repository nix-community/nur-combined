#include <metal_stdlib>
using namespace metal;

struct PS_INPUT
{
    float2 uv0;
};

struct Params
{
    float2 heightMapResolution;
    float3 vScale;
    float terrainWorldSize;
    float4 Hmin;
    float4 Hmax;
    float4 Hsmt;
    float4 Amin;
    float4 Amax;
    float4 Asmt;
    float4 Nonly;
    float3 Nnext;
    float3 Nprev;
    float2 Nnext2;
    float3 Nfreq;
    float3 Noct;
    float3 Npers;
    float3 Npow;
    float2 Nfreq2;
    float2 Noct2;
    float2 Npers2;
    float2 Npow2;
};

float3 mod289(float3 x)
{
    return x - floor(x * (1.0f / 289.0f)) * 289.0f;
}

float2 mod289(float2 x)
{
    return x - floor(x * (1.0f / 289.0f)) * 289.0f;
}

float3 permute(float3 x)
{
    return mod289(((x * 34.0f) + 1.0f) * x);
}

float snoise1(float2 v)
{
    const float4 C = float4(0.211324865405187f, 0.366025403784439f,
                            -0.577350269189626f, 0.024390243902439f);
    float2 i = floor(v + dot(v, C.yy));
    float2 x0 = v - i + dot(i, C.xx);
    float2 i1 = x0.x > x0.y ? float2(1.0f, 0.0f) : float2(0.0f, 1.0f);
    float4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod289(i);
    float3 p = permute(permute(i.y + float3(0.0f, i1.y, 1.0f)) +
                       i.x + float3(0.0f, i1.x, 1.0f));
    float3 m = max(0.5f - float3(dot(x0, x0), dot(x12.xy, x12.xy),
                                 dot(x12.zw, x12.zw)), 0.0f);
    m *= m;
    m *= m;
    float3 x = 2.0f * fract(p * C.www) - 1.0f;
    float3 h = abs(x) - 0.5f;
    float3 ox = floor(x + 0.5f);
    float3 a0 = x - ox;
    m *= 1.79284291400159f - 0.85373472095314f * (a0 * a0 + h * h);
    float3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 0.5f + 0.5f * 130.0f * dot(m, g);
}

float snoise(float2 v, float zoom, int octaves, float persistence)
{
    float total = 0.0f;
    for (int i = 0; i < 5; ++i)
    {
        float frequency = pow(2.0f, float(i));
        float amplitude = pow(persistence, float(i));
        if (i < octaves)
            total += snoise1(v * frequency * zoom) * amplitude;
    }
    return total * ((persistence - 0.1f) * -0.83f + 1.0f);
}

float linRange(float x, float xa, float xb, float s)
{
    float lr = x < xa ? (x - xa) / s + 1.0f : (xb - x) / s + 1.0f;
    return clamp(lr, 0.0f, 1.0f);
}

fragment float4 main_metal
(
    PS_INPUT inPs [[stage_in]],
    texture2d<float, access::read> heightMap [[texture(0)]],
    texture2d<float, access::read> normalMap1 [[texture(1)]],
    constant Params &p [[buffer(PARAMETER_SLOT)]]
)
{
    int2 iCoord = int2(inPs.uv0 * p.heightMapResolution);
    int2 maxCoord = int2(p.heightMapResolution) - 1;
    int3 xN01 = int3(max(iCoord.x - 1, 0), iCoord.x, min(iCoord.x + 1, maxCoord.x));
    int3 yN01 = int3(max(iCoord.y - 1, 0), iCoord.y, min(iCoord.y + 1, maxCoord.y));

    float heightNN = heightMap.read(ushort2(xN01.x, yN01.x)).x * p.vScale.y;
    float heightN0 = heightMap.read(ushort2(xN01.y, yN01.x)).x * p.vScale.y;
    float height0N = heightMap.read(ushort2(xN01.x, yN01.y)).x * p.vScale.y;
    float height00 = heightMap.read(ushort2(xN01.y, yN01.y)).x * p.vScale.y;
    float height01 = heightMap.read(ushort2(xN01.z, yN01.y)).x * p.vScale.y;
    float height10 = heightMap.read(ushort2(xN01.y, yN01.z)).x * p.vScale.y;
    float height11 = heightMap.read(ushort2(xN01.z, yN01.z)).x * p.vScale.y;

    float3 vNN = float3(-p.vScale.x, heightNN, -p.vScale.z);
    float3 vN0 = float3(-p.vScale.x, heightN0, 0.0f);
    float3 v0N = float3(0.0f, height0N, -p.vScale.z);
    float3 v00 = float3(0.0f, height00, 0.0f);
    float3 v01 = float3(0.0f, height01, p.vScale.z);
    float3 v10 = float3(p.vScale.x, height10, 0.0f);
    float3 v11 = float3(p.vScale.x, height11, p.vScale.z);

    float3 vNormal = cross(v01 - v00, v11 - v00) +
                     cross(v11 - v00, v10 - v00) +
                     cross(v10 - v00, v0N - v00) +
                     cross(v0N - v00, vNN - v00) +
                     cross(vNN - v00, vN0 - v00) +
                     cross(vN0 - v00, v01 - v00);
    vNormal = normalize(vNormal);

    float angle = max(0.0f, acos(vNormal.y) * 180.0f / 3.1415926536f);
    float height = heightMap.read(ushort2(iCoord)).x;
    float2 uv1 = float2(inPs.uv0.x, 1.0f - inPs.uv0.y);
    float2 tuv = uv1 * p.terrainWorldSize / 512.0f;

    float4 layerBase = float4(
        p.Nonly.x < 0.1f ? 0.0f : linRange(angle, p.Amin.x, p.Amax.x, p.Asmt.x) * linRange(height, p.Hmin.x, p.Hmax.x, p.Hsmt.x),
        p.Nonly.y < 0.1f ? 0.0f : linRange(angle, p.Amin.y, p.Amax.y, p.Asmt.y) * linRange(height, p.Hmin.y, p.Hmax.y, p.Hsmt.y),
        p.Nonly.z < 0.1f ? 0.0f : linRange(angle, p.Amin.z, p.Amax.z, p.Asmt.z) * linRange(height, p.Hmin.z, p.Hmax.z, p.Hsmt.z),
        p.Nonly.w < 0.1f ? 0.0f : linRange(angle, p.Amin.w, p.Amax.w, p.Asmt.w) * linRange(height, p.Hmin.w, p.Hmax.w, p.Hsmt.w));
    float4 layers = layerBase;

    float3 nextNoise;
    for (uint i = 0; i < 3; ++i)
    {
        float amount = p.Nnext[i] < 0.01f ? 0.0f : p.Nnext[i] * pow(snoise(tuv, p.Nfreq[i], int(p.Noct[i]), p.Npers[i]), p.Npow[i]);
        nextNoise[i] = amount;
    }
    float3 prevNoise;
    for (uint i = 0; i < 3; ++i)
    {
        float amount = p.Nprev[i] < 0.01f ? 0.0f : p.Nprev[i] * pow(snoise(tuv, p.Nfreq[i] + 3.0f, int(p.Noct[i]), p.Npers[i]), p.Npow[i]);
        prevNoise[i] = amount;
    }
    float2 nextNoise2;
    for (uint i = 0; i < 2; ++i)
    {
        float amount = p.Nnext2[i] < 0.01f ? 0.0f : p.Nnext2[i] * pow(snoise(tuv, p.Nfreq2[i], int(p.Noct2[i]), p.Npers2[i]), p.Npow2[i]);
        nextNoise2[i] = amount;
    }

    layers.y += layerBase.x * nextNoise.x; layers.x *= 1.0f - nextNoise.x;
    layers.z += layerBase.y * nextNoise.y; layers.y *= 1.0f - nextNoise.y;
    layers.w += layerBase.z * nextNoise.z; layers.z *= 1.0f - nextNoise.z;
    layers.x += layerBase.y * prevNoise.x; layers.y *= 1.0f - prevNoise.x;
    layers.y += layerBase.z * prevNoise.y; layers.z *= 1.0f - prevNoise.y;
    layers.z += layerBase.w * prevNoise.z; layers.w *= 1.0f - prevNoise.z;
    layers.z += layerBase.x * nextNoise2.x; layers.x *= 1.0f - nextNoise2.x;
    layers.w += layerBase.y * nextNoise2.y; layers.y *= 1.0f - nextNoise2.y;

    layers = clamp(layers, 0.0f, 1.0f);
    float total = dot(layers, float4(1.0f));
    if (total < 0.01f)
    {
        layers = float4(1.0f, 0.0f, 0.0f, 0.0f);
        total = 1.0f;
    }
    return layers / total;
}
