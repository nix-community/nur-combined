# Alibaba's model, fine-tuned to behave like Claude, supposedly optimized for self-hosting; 2026-03-18-ish
# <https://huggingface.co/Jackrong/Qwen3.5-4B-Claude-4.6-Opus-Reasoning-Distilled-v2-GGUF>
{ fetchgit }: fetchgit {
  url = "https://huggingface.co/Jackrong/Qwen3.5-4B-Claude-4.6-Opus-Reasoning-Distilled-v2-GGUF";
  rootDir = "Qwen3.5-4B.Q4_K_M.gguf";
  name = "Qwen3.5-4B-Claude-4.6-Opus-Reasoning-Distilled-v2.gguf";
  fetchLFS = true;
  rev = "40d46d9a653390d33b88ed5f77d7fae110214955";
  hash = "sha256-Cz36btcYoMwC5xvciYImzVHIHq1OkXlnUubt7vk/o8A=";
}
