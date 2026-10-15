{
  pkgs,
  ...
}:
let
  llama-cpp = pkgs.llama-cpp-vulkan;
  llama-cpp-presets = pkgs.writeText "llama-cpp-presets.ini" ''
    [*]
    np = 4
    no-mmproj = true
    no-warmup = true
    sleep-idle-seconds = 1800
    n-gpu-layers = 99
    flash-attn = on
    kv-unified = true
    ctk = q8_0
    ctv = q8_0
    presence-penalty = 1.5
    repeat-penalty = 1.0

    [preset/Ornith-1.5-35B-A3B]
    hf = bartowski/Ornith-1.5-35B-A3B-GGUF:Q4_K_M
    temperature = 0.6
    top-p = 0.95
    top-k = 20
    min-p = 0
    ot = blk\.[0-9]+\.ffn_.*exps.*=CPU
    ctx-size = 131072
  '';
in
{
  services.llama-cpp = {
    enable = true;
    package = llama-cpp;
    settings = {
      models-max = 1;
      "models-preset" = llama-cpp-presets;
    };
  };
  systemd.services.llama-cpp.serviceConfig.Environment = [
    "HOME=/var/cache/llama-cpp"
    "HF_ENDPOINT=https://hf-mirror.com"
  ];
  environment.systemPackages = [
    llama-cpp
  ];
}
