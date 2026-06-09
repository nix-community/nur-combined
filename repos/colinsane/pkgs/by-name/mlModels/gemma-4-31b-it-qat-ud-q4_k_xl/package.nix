# <https://blog.google/innovation-and-ai/technology/developers-tools/quantization-aware-training-gemma-4/>
{ fetchgit }: fetchgit {
  url = "https://huggingface.co/unsloth/gemma-4-31B-it-qat-GGUF";
  rootDir = "gemma-4-31B-it-qat-UD-Q4_K_XL.gguf";
  name = "gemma-4-31B-it-qat-UD-Q4_K_XL.gguf";
  fetchLFS = true;
  rev = "840527d199d2988bdf3656cd8d373e82ea50cb1e";
  hash = "sha256-AkP9wVpZ6VcoF1RyJv+LVkYUBjtodqgQRmLdgHSRV4Q=";
}
