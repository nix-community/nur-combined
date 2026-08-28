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
    sleep-idle-seconds = 600
    n-gpu-layers = 99
    flash-attn = on
    fit = on
    fit-target = 1024
    prio = 3
    kv-unified = true
    repeat-penalty = 1.05

    [preset/Qwen3.6-35B-A3B]
    hf = HauhauCS/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive:Q4_K_M
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
    reasoning = off
    chat-template-file = ${./chat_template.jinja}

    [preset/Qwen3.5-35B-A3B]
    hf = HauhauCS/Qwen3.5-35B-A3B-Uncensored-HauhauCS-Aggressive:Q4_K_M
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
    reasoning = off
    chat-template-file = ${./chat_template.jinja}

    [preset/Gemma4-26B-A4B]
    hf = HauhauCS/Gemma4-26B-A4B-QAT-Uncensored-HauhauCS-Balanced-MTP:Q4_K_M
    temperature = 1.0
    top-p = 0.95
    top-k = 64
    fit = off
    ot = blk\.[0-9]+\.ffn_.*exps.*=CPU
    ctx-size = 131072
    ctk = q8_0
    ctv = q8_0
    reasoning = off
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
