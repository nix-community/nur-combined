# <https://blog.google/innovation-and-ai/technology/developers-tools/quantization-aware-training-gemma-4/>
{ fetchgit }: fetchgit {
  url = "https://huggingface.co/unsloth/gemma-4-12B-it-qat-GGUF";
  rootDir = "gemma-4-12B-it-qat-UD-Q4_K_XL.gguf";
  name = "gemma-4-12B-it-qat-UD-Q4_K_XL.gguf";
  fetchLFS = true;
  rev = "ceadd70e5c46c5a839a7fd622307dabe8fdea551";
  hash = "sha256-qUi+F/3UXl6v4Z0+B2NT2aIcu7oI1eScwtWnUxpib0Y=";
}
