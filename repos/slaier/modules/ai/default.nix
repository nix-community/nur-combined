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
  imports = [
    ./claude-code-router
  ];
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
  sops.secrets.ccr = { };
  services.claude-code-router = {
    enable = true;
    package = pkgs.claude-code-router.overrideAttrs (oldAttrs: rec {
      version = "2.0.1";
      src = pkgs.fetchFromGitHub {
        owner = "wbern";
        repo = "claude-code-router";
        rev = "b77593ba410b80a1d6642484c5ccbc8840a84e17";
        hash = "sha256-swAjX47Ojs7QK4+WINZ6MlScHoDc0k6v5n5syCFjS4w=";
      };

      patches = (oldAttrs.patches or [ ]) ++ [
        ./0001-feat-openai-add-reasoning-effort-support-to-request-.patch
      ];

      pnpmDeps = pkgs.fetchPnpmDeps {
        pnpm = pkgs.pnpm_10;
        inherit (oldAttrs) pname;
        inherit src;
        fetcherVersion = 3;
        hash = "sha256-8184F3ShoC6j7nov35CSZWz2dzPFQC7Bty1iTNs1qzc=";
      };
    });
    settings = {
      NON_INTERACTIVE_MODE = true;
      Providers = [
        {
          name = "gemini";
          api_base_url = "$GEMINI_API_BASE";
          api_key = "$GEMINI_API_KEY";
          models = [
            "gemini-3.1-flash-lite"
            "gemma-4-31b-it"
            "gemma-4-26b-a4b-it"
          ];
          transformer = {
            use = [ "gemini" ];
          };
        }
        {
          name = "openai";
          api_base_url = "$OPENAI_API_BASE";
          api_key = "$OPENAI_API_KEY";
          models = [
            "minimaxai/minimax-m3"
            "moonshotai/kimi-k2.6"
            "deepseek-ai/deepseek-v4-pro"
            "deepseek-ai/deepseek-v4-flash"
            "z-ai/glm-5.1"
          ];
          transformer = {
            use = [ "OpenAI" ];
          };
        }
      ];
      Router = {
        default = "openai,minimaxai/minimax-m3";
        background = "gemini,gemma-4-31b-it";
      };
    };
    environmentFile = config.sops.secrets.ccr.path;
  };
  environment.systemPackages = with pkgs; [
    cherry-studio
    geminicommit
    llama-cpp
    stable-diffusion-cpp-vulkan
  ];
}
