# Google's model, tuned for local inference, released 2026-04-02.
# "small" models are 128k context, "medium" are 256k context.
# <https://deepmind.google/models/gemma/gemma-4/>
# <https://huggingface.co/unsloth/gemma-4-26B-A4B-it-GGUF>
{ fetchFromHuggingFace }: fetchFromHuggingFace {
  owner = "unsloth";
  repo = "gemma-4-26B-A4B-it-GGUF";
  path = "gemma-4-26B-A4B-it-Q8_0.gguf";
  rev = "b8654b48d979f2853b7a81d6541ca64eea7dc3c5";
  hash = "sha256-7BQ9zOyPHHjZuh5Ol4tDBljT+5E9eqVQQUX8Lmma1Kw=";
}
