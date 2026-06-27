# Alibaba's model, fine-tuned to behave like Claude, supposedly optimized for self-hosting.
# <https://huggingface.co/Jackrong/Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-GGUF>
{ fetchFromHuggingFace }: fetchFromHuggingFace {
  owner = "Jackrong";
  repo = "Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-GGUF";
  path = "Qwen3.5-9B.Q3_K_S.gguf";
  name = "Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-Q3_K_S.gguf";
  rev = "406bb1091eda68a59fcd8b138035ffa89addbbf4";
  hash = "sha256-7ciJkhWZrdoiijwUn/6YF4Yyh3vIX1IqmB41YDlcXcc=";
}
