# <https://ollama.com/library/olmo2> (7b, 13b)
# <https://allenai.org/blog/olmo2>
# released 2024-11-26
{ mkOllamaModel }: mkOllamaModel {
  modelName = "olmo2";
  variant = "13b";
  manifestHash = "sha256-bCeevJgPsHyntJzM8XtfrvanMILKxLPUTSImmB3mdto=";
  modelBlob = "cd836509a1a051178be134eba84115eb3a6653a1bd58473a706bf8ee4ab3a764";
  systemBlob = "8b89eea08a537a813b05fbc5edf73b7719a478a06ad69d8d02345294233ffef6";
}
