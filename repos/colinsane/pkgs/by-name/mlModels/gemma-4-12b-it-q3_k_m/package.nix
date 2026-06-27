# Google's model, tuned for local inference, released 2026-06-03.
# <https://blog.google/innovation-and-ai/technology/developers-tools/introducing-gemma-4-12b/>
# <https://huggingface.co/unsloth/gemma-4-12b-it-GGUF>
{ fetchFromHuggingFace }: fetchFromHuggingFace {
  owner = "unsloth";
  repo = "gemma-4-12b-it-GGUF";
  path = "gemma-4-12b-it-Q3_K_M.gguf";
  rev = "517f9a95bf2298825b37cad29dc38ca2b5ed7d62";
  hash = "sha256-0QnqMthDW5kKIae/inU3J6dO/+ALa9DsfLSf4EZWvE4=";
}
