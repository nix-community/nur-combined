# Alibaba's Qwen3.6-35B-A3B, Unsloth Dynamic 2.0 Q4_K_M quant.
# <https://huggingface.co/unsloth/Qwen3.6-35B-A3B-GGUF/blob/main/Qwen3.6-35B-A3B-UD-Q4_K_M.gguf>
# <https://unsloth.ai/docs/models/qwen3.6>
{ fetchFromHuggingFace }: fetchFromHuggingFace {
  owner = "unsloth";
  repo = "Qwen3.6-35B-A3B-GGUF";
  path = "Qwen3.6-35B-A3B-UD-Q4_K_M.gguf";
  rev = "a483e9e6cbd595906af30beda3187c2663a1118c";
  hash = "sha256-OakWBEx6wZYHGezOk0COu3s74dNNVDT6Mb4U4GJpayU=";
}
