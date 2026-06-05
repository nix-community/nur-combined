# Alibaba's model, released 2026-02-15
# <https://huggingface.co/unsloth/Qwen3.5-35B-A3B-GGUF>
# <https://unsloth.ai/docs/models/qwen3.5>
# N.B.: 35B-A3B is allegedly _faster_ than 27B.
{ fetchgit }: fetchgit {
  url = "https://huggingface.co/unsloth/Qwen3.5-35B-A3B-GGUF";
  rootDir =  "Qwen3.5-35B-A3B-Q4_K_M.gguf";
  name = "Qwen3.5-35B-A3B-Q4_K_M.gguf";
  fetchLFS = true;
  rev = "a14e4dbfea4282ed71f22a4af00484bda7772fc0";
  hash = "sha256-mGIn6/lNCBT8oGMF5FTg1b54ccLrTj12B76ySglhBiw=";
}
