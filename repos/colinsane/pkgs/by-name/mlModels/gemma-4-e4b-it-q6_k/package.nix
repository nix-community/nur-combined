# Google's model, tuned for local inference, released 2026-04-02.
# "small" models are 128k context, "medium" are 256k context.
# <https://deepmind.google/models/gemma/gemma-4/>
# <https://huggingface.co/unsloth/gemma-4-E4B-it-GGUF>
{ fetchFromHuggingFace }: fetchFromHuggingFace {
  owner = "unsloth";
  repo = "gemma-4-E4B-it-GGUF";
  path = "gemma-4-E4B-it-Q6_K.gguf";
  rev = "b822b48c259e5dc07b6e8cac20bac0695ba9b549";
  hash = "sha256-zVn6b0KbDmfuthboXRPRubqvDg+Qvoys+Zv0ZNfth48=";
}
