# <https://ollama.com/library/llama4>
# <https://ai.meta.com/blog/llama-4-multimodal-intelligence/>
# released 2025-04-05
{ mkOllamaModel }: mkOllamaModel {
  modelName = "llama4";
  variant = "16x17b";
  manifestHash = "sha256-vzFgTiXCXZZOJQvPKKgr+9voivXyNiV/q7J2Kbskx/M=";
  modelBlob = "9d507a36062c2845dd3bb3e93364e9abc1607118acd8650727a700f72fb126e5";
  modelBlobHash = "sha256-nVB6NgYsKEXdO7PpM2Tpq8FgcRis2GUHJ6cA9y+xJuU=";
  paramsBlob = "bee89e20d457c132784e74ae48177b45262ecc7383c085c835ec54da40d2e4e6";
  paramsBlobHash = "sha256-vuieINRXwTJ4TnSuSBd7RSYuzHODwIXINexU2kDS5OY=";
  systemBlob = "fc1ffc71ab8ebabe8ec0177ea8ee41d1ea27db856636a517d54324eecdfb3f11";
  systemBlobHash = "sha256-/B/8cauOur6OwBd+qO5B0eon24VmNqUX1UMk7s37PxE=";
}
