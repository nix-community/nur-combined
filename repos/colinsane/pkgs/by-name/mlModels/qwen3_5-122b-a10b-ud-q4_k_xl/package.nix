# Alibaba's model, released 2026-03-05.
# <https://huggingface.co/unsloth/Qwen3.5-122B-A10B-GGUF/tree/main/UD-Q4_K_XL>
# <https://unsloth.ai/docs/models/qwen3.5>
{ fetchgit }: fetchgit {
  url = "https://huggingface.co/unsloth/Qwen3.5-122B-A10B-GGUF";
  rootDir = "UD-Q4_K_XL";
  name = "qwen3_5-122b-a10b-ud-q4_k_xl";
  fetchLFS = true;
  rev = "51eab4d59d53f573fb9206cb3ce613f1d0aa392b";
  hash = "sha256-J/sRfJ6q34vr1UgN2+IEdilntdN2TcK4SKMViiDPqiU=";
}
