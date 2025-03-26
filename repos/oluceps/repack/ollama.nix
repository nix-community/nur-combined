{ lib, reIf, ... }:
{
  services.ollama = {
    enable = true;
    environmentVariables = {
      # HIP_VISIBLE_DEVICES = "0,1";
      OLLAMA_LLM_LIBRARY = "cpu";
    };
  };
}
