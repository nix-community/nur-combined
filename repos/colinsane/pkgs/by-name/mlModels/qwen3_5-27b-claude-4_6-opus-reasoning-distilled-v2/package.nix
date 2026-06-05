# Alibaba's model, fine-tuned to behave like Claude, supposedly optimized for self-hosting; 2026-03-18-ish
# <https://huggingface.co/Jackrong/Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled-v2-GGUF>
{ fetchgit }: fetchgit {
  url = "https://huggingface.co/Jackrong/Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled-v2-GGUF";
  rootDir = "Qwen3.5-27B.Q4_K_M.gguf";
  name = "Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled-v2.gguf";
  fetchLFS = true;
  rev = "268a860d70c80f5eafbd9c58443612334747278a";
  hash = "sha256-d8z9BLWGISwIXOUDFYdh4DKo7yKg3BjPNP8bPpiwf58=";
}
