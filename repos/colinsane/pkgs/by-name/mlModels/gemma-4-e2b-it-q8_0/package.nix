# Google's model, tuned for local inference, released 2026-04-02.
# "small" models are 128k context, "medium" are 256k context.
# <https://deepmind.google/models/gemma/gemma-4/>
# <https://huggingface.co/unsloth/gemma-4-E2B-it-GGUF>
{ fetchgit }: fetchgit {
  url = "https://huggingface.co/unsloth/gemma-4-E2B-it-GGUF";
  rootDir = "gemma-4-E2B-it-Q8_0.gguf";
  name = "gemma-4-E2B-it-Q8_0.gguf";
  fetchLFS = true;
  rev = "e18a8a48038a5da3e89c1152441ab57546a70873";
  hash = "sha256-hliIAovn9QHa3NmphcI3CPj2BYmiA22RLmzVx4Tg+3E=";
}
