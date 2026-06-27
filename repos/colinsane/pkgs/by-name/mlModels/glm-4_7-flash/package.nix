# Z.ai's model, released 2026-01-20
# <https://huggingface.co/unsloth/GLM-4.7-Flash-GGUF>
# <https://unsloth.ai/docs/models/glm-4.7-flash>
# <https://docs.z.ai/guides/llm/glm-4.7#glm-4-7-flash>
{ fetchFromHuggingFace }: fetchFromHuggingFace {
  owner = "unsloth";
  repo = "GLM-4.7-Flash-GGUF";
  path = "GLM-4.7-Flash-Q4_K_M.gguf";
  rev = "bc383b21e43b880a69b6a0a3d41f26710c3608f3";
  hash = "sha256-U5kOx/V9DW/ezUTlU8LrqHeMN3um1Zg8+oxMqqJvKC0=";
}
