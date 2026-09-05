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

  # Parent disk is 0700 lucasew; llama/ is 0750 llama. Grant execute so the
  # service can reach its own tree. Do not pass --models-dir: that path was
  # never created and llama-server does not need it for an hf-repo preset.
  systemd.tmpfiles.rules = [
    "a /media/ssd1tb - - - - u:llama:--x"
    "d ${dataDir} 0750 llama llama -"
    "d ${dataDir}/cache 0750 llama llama -"
  ];

  services.llama-cpp = {
    enable = true;
    package = llamaCpp;
    # 0.0.0.0 so MagicDNS "whiterun" works here (127.0.0.2) and on the tailnet.
    # LAN stays closed; tailscale0 is already a trusted interface.
    host = "0.0.0.0";
    inherit (config.networking.ports.llama-cpp) port;
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

  systemd.services.llama-cpp = {
    after = [
      "tailscaled.service"
      "tailscale-autoconnect.service"
    ];
    wants = [ "tailscaled.service" ];
    unitConfig.RequiresMountsFor = [ "/media/ssd1tb" ];
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "llama";
      Group = "llama";
      ReadWritePaths = [ dataDir ];
      Environment = [ "LLAMA_CACHE=${dataDir}/cache" ];
      TimeoutStartSec = "infinity";
    };
  };
}
