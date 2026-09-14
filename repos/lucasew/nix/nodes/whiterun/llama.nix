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
    # 0.0.0.0 so MagicDNS "whiterun" reaches this process on the tailnet.
    # LAN stays closed; tailscale0 is already a trusted interface.
    host = "0.0.0.0";
    inherit (config.networking.ports.llama-cpp) port;
    # Router: one model at a time. The 35B-A3B is ~23 GB plus KV; a 12 GB
    # 3060 cannot keep it and qwen3.5-9b resident together.
    extraFlags = [
      "--models-max"
      "1"
    ];
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
      # Cyber-Tiel 35B-A3B MTP UD-Q4_K_XL (~22.7 GB). 12 GB 3060: ngl 99 +
      # n-cpu-moe 27 (do not use 41 — that parks the MTP head on CPU).
      # draft-mtp is required or the grafted head is unused. mmproj stays
      # in RAM: at n-cpu-moe 25 the weights already fill the card, then
      # CLIP's 861 MiB cudaMalloc aborts the child.
      "cyber-tiel-coder-35b" = {
        hf-repo = "peculiar-ragdoll/Cyber-Tiel-Coder-35B-A3B-GGUF-MTP";
        hf-file = "Cyber-Tiel-Coder-35B-A3B-MTP-UD-Q4_K_XL.gguf";
        mmproj-url = "https://huggingface.co/peculiar-ragdoll/Cyber-Tiel-Coder-35B-A3B-GGUF-MTP/resolve/main/mmproj-BF16.gguf";
        no-mmproj-offload = "on";
        alias = "cyber-tiel-coder-35b";
        ngl = "99";
        n-cpu-moe = "27";
        ctx-size = "131072";
        flash-attn = "on";
        parallel = "1";
        cache-type-k = "q4_0";
        cache-type-v = "q4_0";
        jinja = "on";
        spec-type = "draft-mtp";
        spec-draft-n-max = "2";
        temp = "0.6";
        top-p = "0.95";
        top-k = "20";
        min-p = "0";
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
