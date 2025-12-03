# <https://ollama.com/library/orca-mini> (3b, 7b, 13b, 70b)
# released 2023-06-23
{ mkOllamaModel }: mkOllamaModel {
  modelName = "orca-mini";
  variant = "7b";
  manifestHash = "sha256-nJYY4uiVL6LC+sSYbMEokjvTbyOWOdezGtJpLybebas=";
  modelBlob = "40ac7cfa75a3e4895f713126633775dd7342c08307b2c5e6e518006072af3cf5";
  modelBlobHash = "sha256-QKx8+nWj5IlfcTEmYzd13XNCwIMHssXm5RgAYHKvPPU=";
  paramsBlob = "29f7936d3d8c5cf0d3d73036cfbdeb807b7a8cbe33887c4da313139bb9ec57ad";
  paramsBlobHash = "sha256-KfeTbT2MXPDT1zA2z73rgHt6jL4ziHxNoxMTm7nsV60=";
  systemBlob = "93ca9b3d83dc541f11062c0b994ae66a7b327146f59a9564aafef4a4c15d1ef5";
  systemBlobHash = "sha256-k8qbPYPcVB8RBiwLmUrmansycUb1mpVkqv70pMFdHvU=";
}
