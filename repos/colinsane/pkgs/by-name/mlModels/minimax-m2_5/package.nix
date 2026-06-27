# released 2026-02-12
# <https://huggingface.co/unsloth/MiniMax-M2.5-GGUF>
# <https://unsloth.ai/docs/models/minimax-m25>
# <https://www.minimax.io/news/minimax-m25>
#
# this is a multi-file model -- not sure the intended way to use this?
# i'll just replicate the folder layout
{ fetchFromHuggingFace }: fetchFromHuggingFace {
  owner = "unsloth";
  repo = "MiniMax-M2.5-GGUF";
  path = "UD-Q3_K_XL";
  name = "MiniMax-M2.5-UD-Q3_K_XL.gguf";
  rev = "7c50dca0e5592483ad308ecffc876aecac725660";
  hash = "sha256-twE8CqNFYzAHFSG0vOfekcEkVhpdyES4NlJL8j3BWE8=";
}
