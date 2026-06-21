# Alibaba's Qwen3.6-35B-A3B (MTP variant), Unsloth Dynamic 2.0 Q4_K_M quant.
# <https://huggingface.co/unsloth/Qwen3.6-35B-A3B-MTP-GGUF/blob/main/Qwen3.6-35B-A3B-UD-Q4_K_M.gguf>
# <https://unsloth.ai/docs/models/qwen3.6>
{ fetchgit }: fetchgit {
  url = "https://huggingface.co/unsloth/Qwen3.6-35B-A3B-MTP-GGUF";
  rootDir = "Qwen3.6-35B-A3B-UD-Q4_K_M.gguf";
  name = "Qwen3.6-35B-A3B-UD-Q4_K_M.gguf";
  fetchLFS = true;
  rev = "5bc3e238d916f48a861bac2f8a1990a0e9b7e98d";
  hash = "sha256-1Mc4/W/N5vHRW3tVJsnqaZn+YYvQWJWb82tyyT1MICw=";
}
