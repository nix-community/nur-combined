# <https://ollama.com/library/dolphin3> (8b)
# "Dolphin 3.0 Llama 3.1 8B 🐬 is the next generation of the Dolphin series of instruct-tuned models designed to be the ultimate general purpose local model, enabling coding, math, agentic, function calling, and general use cases."
# released 2024-12-29
{ mkOllamaModel }: mkOllamaModel {
  modelName = "dolphin3";
  variant = "8b";
  manifestHash = "sha256-1aua6OHyJhmmvlLlaU30IrcYOjiDmQoAAYjDY3gey3g=";
  modelBlob = "1eee6953530837b2b17d61a4e6f71a5aa31c9714cfcf3cb141aa5c1972b5116b";
  modelBlobHash = "sha256-Hu5pU1MIN7KxfWGk5vcaWqMclxTPzzyxQapcGXK1EWs=";
  paramsBlob = "f02dd72bb2423204352eabc5637b44d79d17f109fdb510a7c51455892aa2d216";
  paramsBlobHash = "sha256-8C3XK7JCMgQ1LqvFY3tE150X8Qn9tRCnxRRViSqi0hY=";
  systemBlob = "8b586b146d99262cc7bf20f47faa5507dd5c8476967be9e03822262361204637";
  systemBlobHash = "sha256-i1hrFG2ZJizHvyD0f6pVB91chHaWe+ngOCImI2EgRjc=";
}
