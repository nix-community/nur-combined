# <https://ollama.com/library/nemotron-3-nano> (30b)
# <https://research.nvidia.com/labs/nemotron/Nemotron-3/>
# released 2025-12-15
{ mkOllamaModel }: mkOllamaModel {
  modelName = "nemotron-3-nano";
  variant = "30b";
  manifestHash = "sha256-tyXxEXQHMzTt0ML/OWuNTmbX2rIqWmNxfMrVoIonDPE=";
  modelBlob = "a70437c41b3b0b768c48737e15f8160c90f13dc963f5226aabb3a160f708d1ce";
  paramsBlob = "12e88b2a8727339b5a4a8b3e2d0d637ac1c61085b1072e77865f0c25d6e468eb";
}
