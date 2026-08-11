{ pkgs, ... }: {
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda; # CUDA backend enables local inference on the RTX 4080 SUPER.
  };

  environment.sessionVariables.OLLAMA_HOST = "127.0.0.1:11434"; # Keep the model API local.
}
