# <https://huggingface.co/unsloth/Qwen3.5-35B-A3B-GGUF>
# <https://unsloth.ai/docs/models/qwen3.5>
# N.B.: 35B-A3B is allegedly _faster_ than 27B.
{ mkOllamaModel }: mkOllamaModel {
  owner = "unsloth";
  modelName = "Qwen3.5-35B-A3B-GGUF";
  variant = "Q4_K_M";
  manifestHash = "sha256-olsU1JRZ6hv6spgHWqZ3g/ebp2q6eWAYDq6v6D1CT9s=";
  modelBlob = "e8c60ba898493e3b8141c287ecb016c9bcaa9d8e745775ef26cc81511945a673";
  projectorBlob = "b77b00b0a785f5f67522bbd42387afd684a879ab7b060743bfe95d624b51ebbe";
}
