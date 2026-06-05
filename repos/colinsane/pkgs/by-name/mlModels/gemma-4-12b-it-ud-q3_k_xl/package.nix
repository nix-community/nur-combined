# Google's model, tuned for local inference, released 2026-06-03.
# <https://blog.google/innovation-and-ai/technology/developers-tools/introducing-gemma-4-12b/>
# <https://huggingface.co/unsloth/gemma-4-12b-it-GGUF>
{ fetchgit }: fetchgit {
  url = "https://huggingface.co/unsloth/gemma-4-12b-it-GGUF";
  rootDir = "gemma-4-12b-it-UD-Q3_K_XL.gguf";
  name = "gemma-4-12b-it-UD-Q3_K_XL.gguf";
  fetchLFS = true;
  rev = "517f9a95bf2298825b37cad29dc38ca2b5ed7d62";
  hash = "sha256-hi9nfQb//QmAFJG2BAoFX4cYMqak15R7BE2hHY29jI8=";
}
