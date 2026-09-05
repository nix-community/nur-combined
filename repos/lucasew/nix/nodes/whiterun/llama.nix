{
  config,
  lib,
  pkgs,
  ...
}:
let
  dataDir = "/media/ssd1tb/llama";
  llamaCpp = pkgs.unstable.llama-cpp.override { cudaSupport = true; };
in
{
  networking.ports.llama-cpp.enable = true;

  environment.systemPackages = [ llamaCpp ];

  users.users.llama = {
    isSystemUser = true;
    group = "llama";
    home = dataDir;
  };
  users.groups.llama = { };

  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 llama llama -"
    "d ${dataDir}/models 0750 llama llama -"
    "d ${dataDir}/cache 0750 llama llama -"
  ];

  services.llama-cpp = {
    enable = true;
    package = llamaCpp;
    host = "127.0.0.1";
    inherit (config.networking.ports.llama-cpp) port;
    modelsDir = "${dataDir}/models";
    # Qwen3.5-9B Q4_K_M + matching F16 projector from the same HF repo.
    # llama-server pulls both into LLAMA_CACHE. -ngl 99, no CPU offload.
    modelsPreset = {
      "qwen3.5-9b" = {
        hf-repo = "unsloth/Qwen3.5-9B-GGUF";
        hf-file = "Qwen3.5-9B-Q4_K_M.gguf";
        mmproj-url = "https://huggingface.co/unsloth/Qwen3.5-9B-GGUF/resolve/main/mmproj-F16.gguf";
        alias = "qwen3.5-9b";
        ngl = "99";
        ctx-size = "131072";
        flash-attn = "on";
        parallel = "1";
        cache-type-k = "q4_0";
        cache-type-v = "q4_0";
        jinja = "on";
      };
    };
  };

  systemd.services.llama-cpp.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "llama";
    Group = "llama";
    ReadWritePaths = [ dataDir ];
    Environment = [ "LLAMA_CACHE=${dataDir}/cache" ];
    TimeoutStartSec = "infinity";
  };
}
