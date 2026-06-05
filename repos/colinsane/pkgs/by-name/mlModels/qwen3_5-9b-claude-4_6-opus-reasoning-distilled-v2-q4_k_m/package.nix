# Alibaba's model, fine-tuned to behave like Claude, supposedly optimized for self-hosting; 2026-03-18-ish
# <https://huggingface.co/Jackrong/Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-v2-GGUF>
{ fetchgit }: fetchgit {
  url = "https://huggingface.co/Jackrong/Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-v2-GGUF";
  rootDir = "Qwen3.5-9B.Q4_K_M.gguf";
  name = "Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-v2-Q4_K_M.gguf";
  fetchLFS = true;
  rev = "81b88fc606f0cd77c88fb9b1e0d4e075e7c69eb5";
  hash = "sha256-ApoHpWRsUAWbtDni6k9/xawZa8rm96tv5Tlkuu/n9oI=";
}
