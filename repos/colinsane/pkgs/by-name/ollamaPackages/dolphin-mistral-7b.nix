# <https://ollama.com/library/dolphin-mistral>
# uncensored version of mistral
{ mkOllamaModel }: mkOllamaModel {
  modelName = "dolphin-mistral";
  variant = "7b";
  manifestHash = "sha256-XcjFor5lENyyr7z/3txzrL1YaNLCXZQC9gRL6t49X3A=";
  modelBlob = "11a57a9bd0bc7d5e12aa0cc3d83e8d34b776fe5a8c232b20d610ca9f4e8b4b23";
  modelBlobHash = "sha256-EaV6m9C8fV4SqgzD2D6NNLd2/lqMIysg1hDKn06LSyM=";
  paramsBlob = "f02dd72bb2423204352eabc5637b44d79d17f109fdb510a7c51455892aa2d216";
  paramsBlobHash = "sha256-8C3XK7JCMgQ1LqvFY3tE150X8Qn9tRCnxRRViSqi0hY=";
  systemBlob = "9640c2212a51f7df5840f7929448afa17cb33fbb173cf15e1d74883e932a3466";
  systemBlobHash = "sha256-lkDCISpR999YQPeSlEivoXyzP7sXPPFeHXSIPpMqNGY=";
}
