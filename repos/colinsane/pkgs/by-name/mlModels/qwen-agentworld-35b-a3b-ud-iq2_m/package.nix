# Qwen-AgentWorld-35B-A3B world model, quantized with IQ2_M.
# Released 2026-06-25 by unsloth.
# <https://huggingface.co/unsloth/Qwen-AgentWorld-35B-A3B-GGUF>
{ fetchFromHuggingFace }: fetchFromHuggingFace {
  owner = "unsloth";
  repo = "Qwen-AgentWorld-35B-A3B-GGUF";
  path = "Qwen-AgentWorld-35B-A3B-UD-IQ2_M.gguf";
  rev = "7868b2353f2787df35b4944fee1f4d3dd274498f";  # N.B.: future revs drop the .gitattributes entry for the IQ2_M variant
  hash = "sha256-8ilVV3TX/mT0eQFlVFaJoLtrCnrLREcFA8SMWAL0cRM=";
}
# { fetchurl }: fetchurl {
#   url = "https://huggingface.co/unsloth/Qwen-AgentWorld-35B-A3B-GGUF/resolve/3a305abf5cfd119ee999dfe929c433746edd8d63/Qwen-AgentWorld-35B-A3B-UD-IQ2_M.gguf";
#   hash = "sha256-xKtIwNS7FQq/l/IrqsmC/51Pg7UUuAgW6aGdfH1eAt0=";
# }
