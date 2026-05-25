{
  config,
  pkgs,
  ...
}:
let
  llama-cpp = pkgs.llama-cpp-vulkan;
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
          model_name = "gemini-chat";
          litellm_params = {
            model = "gemini/gemini-3.1-flash-lite";
            api_base = "os.environ/GEMINI_API_BASE";
            api_key = "os.environ/GEMINI_API_KEY";
            rpm = 15;
            tpm = 250000;
            weight = 1;
          };
        }
        {
          model_name = "gemini-chat";
          litellm_params = {
            model = "gemini/gemma-4-26b-a4b-it";
            api_base = "os.environ/GEMINI_API_BASE";
            api_key = "os.environ/GEMINI_API_KEY";
            rpm = 15;
            weight = 3;
          };
        }
        {
          model_name = "gemini-chat";
          litellm_params = {
            model = "gemini/gemma-4-31b-it";
            api_base = "os.environ/GEMINI_API_BASE";
            api_key = "os.environ/GEMINI_API_KEY";
            rpm = 15;
            weight = 3;
          };
        }
        {
          model_name = "gemini-embedding";
          litellm_params = {
            model = "gemini/gemini-embedding-2";
            api_base = "os.environ/GEMINI_API_BASE";
            api_key = "os.environ/GEMINI_API_KEY";
            rpm = 100;
            tpm = 30000;
          };
        }
        {
          model_name = "gemini-embedding";
          litellm_params = {
            model = "gemini/gemini-embedding-1";
            api_base = "os.environ/GEMINI_API_BASE";
            api_key = "os.environ/GEMINI_API_KEY";
            rpm = 100;
            tpm = 30000;
          };
        }
        {
          model_name = "mimo-v2.5-pro";
          litellm_params = {
            model = "xiaomi_mimo/mimo-v2.5-pro";
            api_base = "os.environ/XIAOMI_MIMO_API_BASE";
            api_key = "os.environ/XIAOMI_MIMO_API_KEY";
            rpm = 100;
            tpm = 10000000;
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
  sops.secrets.litellm = {
    format = "dotenv";
    key = "";
    sopsFile = ../../secrets/litellm.env;
  };
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
      "preset/Jan-v3-4B-base-instruct" = {
        hf = "janhq/Jan-v3-4B-base-instruct-gguf";
        temperature = 0.7;
        top-p = 0.8;
        top-k = 20;
        min-p = 0;
        presence-penalty = 1.5;
        repeat-penalty = 1.0;
        ctk = "q8_0";
        ctv = "q8_0";
      };
      "preset/Qwen2.5-Coder-3B-Instruct-128K" = {
        hf = "unsloth/Qwen2.5-Coder-3B-Instruct-128K-GGUF:Q4_K_M";
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
    aicommits
    cherry-studio
    llama-cpp
    stable-diffusion-cpp-vulkan
  ];
}
