{
  config,
  pkgs,
  ...
}:
let
  llama-cpp = pkgs.llama-cpp-vulkan;
  llama-cpp-presets = pkgs.writeText "llama-cpp-presets.ini" ''
    [*]
    np = 1
    no-mmproj = true
    no-warmup = true
    sleep-idle-seconds = 600
    n-gpu-layers = 99
    flash-attn = on
    fit = on
    fit-target = 1024
    prio = 3
    kv-unified = true
    repeat-penalty = 1.05

    [preset/Qwen3.6-35B-A3B-MTP]
    hf = unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL
    temperature = 0.7
    top-p = 0.8
    top-k = 20
    min-p = 0
    presence-penalty = 1.5
    repeat-penalty = 1.0
    fit = off
    ot = blk\.[0-9]+\.ffn_.*exps.*=CPU
    ctx-size = 131072
    ctk = q8_0
    ctv = q8_0
    spec-type = draft-mtp
    spec-draft-n-max = 1

    [preset/Qwen3.5-4B-MTP]
    hf = unsloth/Qwen3.5-4B-MTP-GGUF:UD-Q4_K_XL
    temperature = 0.7
    top-p = 0.8
    top-k = 20
    min-p = 0
    presence-penalty = 1.5
    repeat-penalty = 1.0
    ctx-size = 131072
    ctk = q8_0
    ctv = q8_0

    [preset/MiniCPM5-1B]
    hf = openbmb/MiniCPM5-1B-GGUF:Q8_0
    temperature = 0.7
    top-p = 0.95

    [preset/Hy-MT2-1.8B-GGUF]
    hf = tencent/Hy-MT2-1.8B-GGUF:Q4_K_M
    temperature = 0.7
    top-p = 0.6
    top-k = 20
    repeat-penalty = 1.05
    ctk = q8_0
    ctv = q8_0
  '';
in
{
  services.litellm = {
    enable = true;
    package = pkgs.litellm.overrideAttrs (prev: {
      propagatedBuildInputs = prev.propagatedBuildInputs ++ [
        pkgs.python3Packages.diskcache
      ];
    });
    port = 4000;
    environmentFile = config.sops.secrets.litellm.path;
    settings = {
      model_list = [
        {
          model_name = "stepfun-ai/step-3.5-flash";
          litellm_params = {
            model = "nvidia_nim/stepfun-ai/step-3.5-flash";
            api_key = "os.environ/NVIDIA_NIM_API_KEY";
          };
        }
      ];
      litellm_settings = {
        cache = true;
        cache_params = {
          type = "disk";
          disk_cache_dir = "/var/cache/litellm";
        };
        drop_params = true;
      };
    };
  };
  systemd.services.litellm.serviceConfig.CacheDirectory = "litellm";
  sops.secrets.litellm = { };
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
  environment.systemPackages = with pkgs; [
    geminicommit
    llama-cpp
    stable-diffusion-cpp-vulkan
  ];
}
