# Google's model, tuned for local inference, released 2026-06-03.
# <https://blog.google/innovation-and-ai/technology/developers-tools/introducing-gemma-4-12b/>
# <https://huggingface.co/unsloth/gemma-4-12b-it-GGUF>
{ fetchgit }: fetchgit {
  url = "https://huggingface.co/unsloth/gemma-4-12b-it-GGUF";
  rootDir = "gemma-4-12b-it-UD-IQ3_XXS.gguf";
  name = "gemma-4-12b-it-UD-IQ3_XXS.gguf";
  fetchLFS = true;
  rev = "517f9a95bf2298825b37cad29dc38ca2b5ed7d62";
  hash = "sha256-3n7xMXZZWohp2RjxBU4frnDU1+URcoE3tbuDfqYkXLw=";
}
