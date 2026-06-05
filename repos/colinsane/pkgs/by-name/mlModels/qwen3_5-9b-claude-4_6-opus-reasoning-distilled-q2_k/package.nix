# Alibaba's model, fine-tuned to behave like Claude, supposedly optimized for self-hosting.
# <https://huggingface.co/Jackrong/Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-GGUF>
{ fetchgit }: fetchgit {
  url = "https://huggingface.co/Jackrong/Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-GGUF";
  rootDir = "Qwen3.5-9B.Q2_K.gguf";
  name = "Qwen3.5-9B-Claude-4.6-Opus-Reasoning-Distilled-Q2_K.gguf";
  fetchLFS = true;
  rev = "406bb1091eda68a59fcd8b138035ffa89addbbf4";
  hash = "sha256-kb2u+PluClVAfZVvniieSVVYKkADjn5DmwQqAd4TuSc=";
}
