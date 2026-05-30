{
  pkgs,
  ...
}:
let
  llama-cpp = pkgs.llama-cpp-vulkan;
in
{
  services.llama-cpp = {
    enable = true;
    package = llama-cpp;
    extraFlags = [
      "--models-max"
      "1"
    ];
    modelsPreset = {
      "*" = {
        np = 1;
        no-mmproj = true;
        no-warmup = true;
        sleep-idle-seconds = 600;
        n-gpu-layers = 99;
        flash-attn = "on";
        fit = "on";
        fit-target = 1024;
        prio = 3;
        kv-unified = true;
        repeat-penalty = 1.05;
        reasoning = "off";
      };

      "preset/Qwen3.6-35B-A3B-MTP" = {
        hf = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL";
        temperature = 0.7;
        top-p = 0.8;
        top-k = 20;
        min-p = 0;
        presence-penalty = 1.5;
        repeat-penalty = 1.0;
        fit = "off";
        ot = ''blk\.[0-9]+\.ffn_.*exps.*=CPU'';
        ctx-size = 204800;
        ctk = "q8_0";
        ctv = "q8_0";
        spec-type = "draft-mtp";
        spec-draft-n-max = 1;
      };
      "preset/Qwen3.5-4B-MTP" = {
        hf = "unsloth/Qwen3.5-4B-MTP-GGUF:UD-Q4_K_XL";
        temperature = 0.7;
        top-p = 0.8;
        top-k = 20;
        min-p = 0;
        presence-penalty = 1.5;
        repeat-penalty = 1.0;
        ctk = "q8_0";
        ctv = "q8_0";
      };
      "preset/MiniCPM5-1B" = {
        hf = "openbmb/MiniCPM5-1B-GGUF:Q8_0";
        temperature = 0.7;
        top-p = 0.95;
      };
      "preset/Hy-MT2-1.8B-GGUF" = {
        hf = "tencent/Hy-MT2-1.8B-GGUF:Q4_K_M";
        temperature = 0.7;
        top-p = 0.6;
        top-k = 20;
        repeat-penalty = 1.05;
        ctk = "q8_0";
        ctv = "q8_0";
      };
    };
  };
  systemd.services.llama-cpp.serviceConfig.Environment = [
    "HOME=/var/cache/llama-cpp"
    "HF_ENDPOINT=https://hf-mirror.com"
  ];
  environment.systemPackages = with pkgs; [
    cherry-studio
    geminicommit
    llama-cpp
    stable-diffusion-cpp-vulkan
  ];
}
