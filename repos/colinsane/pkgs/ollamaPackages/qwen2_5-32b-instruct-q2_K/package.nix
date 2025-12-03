# <https://ollama.com/library/qwen2.5>
# - 32b-instruct-q2_K is a variant of 32b that's 12 GB instead of 20 GB
#   14b-instruct is 9 GB, for comparison
{ mkOllamaModel }: mkOllamaModel {
  modelName = "qwen2.5";
  variant = "32b-instruct-q2_K";
  manifestHash = "sha256-mYGFobYa4TEkAb+xBICAnmieSgYsTT+FbQNxGSWReNI=";
  modelBlob = "ed7a653589dcc230070e02058681ad28ba202ddbd6b79e3dcbf23e436d5e8f00";
  modelBlobHash = "sha256-7XplNYncwjAHDgIFhoGtKLogLdvWt549y/I+Q21ejwA=";
  systemBlob = "66b9ea09bd5b7099cbb4fc820f31b575c0366fa439b08245566692c6784e281e";
  systemBlobHash = "sha256-ZrnqCb1bcJnLtPyCDzG1dcA2b6Q5sIJFVmaSxnhOKB4=";
}
