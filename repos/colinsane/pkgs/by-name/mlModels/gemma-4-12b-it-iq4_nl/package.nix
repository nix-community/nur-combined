# Google's model, tuned for local inference, released 2026-06-03.
# <https://blog.google/innovation-and-ai/technology/developers-tools/introducing-gemma-4-12b/>
# <https://huggingface.co/unsloth/gemma-4-12b-it-GGUF>
{ fetchFromHuggingFace }: fetchFromHuggingFace {
  owner = "unsloth";
  repo = "gemma-4-12b-it-GGUF";
  path = "gemma-4-12b-it-IQ4_NL.gguf";
  rev = "517f9a95bf2298825b37cad29dc38ca2b5ed7d62";
  hash = "sha256-qVu1KWIU2Tb2GrSRtEijuvhtcnmxVJ/+DZkZtK/o00Y=";
}
