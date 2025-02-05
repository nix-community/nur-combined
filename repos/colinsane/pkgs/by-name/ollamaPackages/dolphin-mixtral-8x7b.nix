# <https://ollama.com/library/dolphin-mixtral>
# uncensored version of mixtral
{ mkOllamaModel }: mkOllamaModel {
  modelName = "dolphin-mixtral";
  variant = "8x7b";
  manifestHash = "sha256-T3bCjAQUPqeMr+MYmDy76wva0WqZNlw5uBizrI/lADc=";
  modelBlob = "5041ba4278429fe475782b889471b5ff065a6cce5c3a539bd61d1e457f1961de";
  modelBlobHash = "sha256-UEG6QnhCn+R1eCuIlHG1/wZabM5cOlOb1h0eRX8ZYd4=";
  paramsBlob = "f02dd72bb2423204352eabc5637b44d79d17f109fdb510a7c51455892aa2d216";
  paramsBlobHash = "sha256-8C3XK7JCMgQ1LqvFY3tE150X8Qn9tRCnxRRViSqi0hY=";
  systemBlob = "9640c2212a51f7df5840f7929448afa17cb33fbb173cf15e1d74883e932a3466";
  systemBlobHash = "sha256-lkDCISpR999YQPeSlEivoXyzP7sXPPFeHXSIPpMqNGY=";
}
