# <https://ollama.com/library/deepseek-coder-v2>
# - normal 16b is 8.9 GB; 16b-lite-instruct-q5_1 is 12 GB
{ mkOllamaModel }: mkOllamaModel {
  modelName = "deepseek-coder-v2";
  variant = "16b-lite-instruct-q5_1";
  manifestHash = "sha256-8U8LWP7e8jUMjjeooHn9tT/GX9UXIfIJrzGAB8aLRmQ=";
  modelBlob = "7d9a741801702d521029cf790c40f9b473e9ecfb5fd65b6eb6b03eb07f8e4ff4";
  modelBlobHash = "sha256-fZp0GAFwLVIQKc95DED5tHPp7Ptf1ltutrA+sH+OT/Q=";
  paramsBlob = "19f2fb9e8bc65a143f47903ec07dce010fd2873f994b900ea735a4b5022e968d";
  paramsBlobHash = "sha256-GfL7novGWhQ/R5A+wH3OAQ/Shz+ZS5AOpzWktQIulo0=";
}
