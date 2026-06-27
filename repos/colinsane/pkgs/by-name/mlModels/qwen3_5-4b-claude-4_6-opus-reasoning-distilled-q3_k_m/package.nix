# Alibaba's model, fine-tuned to behave like Claude, supposedly optimized for self-hosting.
# <https://huggingface.co/Jackrong/Qwen3.5-4B-Claude-4.6-Opus-Reasoning-Distilled-GGUF>
{ fetchFromHuggingFace }: fetchFromHuggingFace {
  owner = "Jackrong";
  repo = "Qwen3.5-4B-Claude-4.6-Opus-Reasoning-Distilled-GGUF";
  path = "Qwen3.5-4B.Q3_K_M.gguf";
  name = "Qwen3.5-4B-Claude-4.6-Opus-Reasoning-Distilled-Q3_K_M.gguf";
  rev = "e512aa48e30fc2a64d55e907631be3740977b1f8";
  hash = "sha256-srpZrz6cauVvQVLU/vlC8F2IXz/Yzfzxn+RGC0njSAU=";
}
