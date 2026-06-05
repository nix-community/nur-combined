# <https://ollama.com/library/deepseek-r1>
# uncensored version of deepseek-r1
{ mkOllamaModel }: mkOllamaModel {
  owner = "huihui_ai";
  modelName = "deepseek-r1-abliterated";
  variant = "32b";
  manifestHash = "sha256-+1OzKWkSroqT/1xpORgrdd+PREiAWv3FA5zP7tyncgQ=";
  modelBlob = "b3bc1a1ad6d5654cd7d8200389f6a96f84f832a5049c003bd47b168078fdf582";
  paramsBlob = "f4d24e9138dd4603380add165d2b0d970bef471fac194b436ebd50e6147c6588";
}
