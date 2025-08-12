{ lib, reIf, ... }:
{
  services.ollama = {
    enable = true;
    environmentVariables = {
      # HIP_VISIBLE_DEVICES = "0,1";
      OLLAMA_LLM_LIBRARY = "cpu";
      OLLAMA_ORIGINS = "http://192.168.*";
    };
    host = "[::]";
  };
}
