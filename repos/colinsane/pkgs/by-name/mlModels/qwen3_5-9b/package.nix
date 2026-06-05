# Alibaba's model, released 2026-02-15
# <https://huggingface.co/unsloth/Qwen3.5-9B-GGUF/blob/main/Qwen3.5-9B-Q4_K_M.gguf>
# <https://unsloth.ai/docs/models/qwen3.5>
{ fetchgit }: fetchgit {
  url = "https://huggingface.co/unsloth/Qwen3.5-9B-GGUF";
  rootDir = "Qwen3.5-9B-Q4_K_M.gguf";
  name = "Qwen3.5-9B-Q4_K_M.gguf";
  fetchLFS = true;
  rev = "3885219b6810b007914f3a7950a8d1b469d598a5";
  hash = "sha256-I2pL5fsfHxqfHs6wIVCyyjSLQ/9mQrXvxXQ6pVE6PQ0=";
}
