# <https://blog.google/innovation-and-ai/technology/developers-tools/quantization-aware-training-gemma-4/>
{ fetchgit }: fetchgit {
  url = "https://huggingface.co/unsloth/gemma-4-26B-A4B-it-qat-GGUF";
  rootDir = "gemma-4-26B-A4B-it-qat-UD-Q4_K_XL.gguf";
  name = "gemma-4-26B-A4B-it-qat-UD-Q4_K_XL.gguf";
  fetchLFS = true;
  rev = "df8f95ac194275cab887832cca126da33616b425";
  hash = "sha256-3PUz32Czq53Efj/nkzn851INH3nWKsWmqCgWqNhvJHs=";
}
