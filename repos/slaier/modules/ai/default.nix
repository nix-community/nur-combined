{ config, lib, pkgs, utils, inputs, ... }:
{
  services.litellm = {
    enable = true;
    package = pkgs.litellmUnstable;
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
      ];
    };
  };
  sops.secrets.litellm = {
    format = "dotenv";
    key = "";
    sopsFile = ../../secrets/litellm.env;
  };
  systemd.services.llama-cpp = {
    description = "LLaMA C++ server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "idle";
      KillSignal = "SIGINT";
      StateDirectory = "llama-cpp";
      CacheDirectory = "llama-cpp";
      WorkingDirectory = "/var/lib/llama-cpp";
      Environment = [
        "LLAMA_CACHE=/var/cache/llama-cpp"
        "HOME=/var/cache/llama-cpp"
        "HF_ENDPOINT=https://hf-mirror.com"
      ];
      ExecStart =
        let
          preset = pkgs.writeText "llama-models.ini" (lib.generators.toINI { } {
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

            # Coder
            "Qwen3.6-35B-A3B" = {
              hf = "unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q4_K_M";
              temperature = 0.7;
              top-p = 0.8;
              top-k = 20;
              min-p = 0;
              presence-penalty = 1.5;
              repeat-penalty = 1.0;
              fit = "off";
              ot = ''blk\.[0-9]+\.ffn_.*exps.*=CPU'';
              ctk = "q8_0";
              ctv = "q8_0";
            };
            "Jan-v3-4B-base-instruct" = {
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
            "Qwen2.5-Coder-1.5B-CodeFIM" = {
              hf = "mradermacher/Qwen2.5-Coder-1.5B-CodeFIM-GGUF:Q4_K_M";
            };
            "FastApply-1.5B-v1.0" = {
              hf = "MaziyarPanahi/FastApply-1.5B-v1.0-GGUF:Q5_K_M";
            };
            "nomic-embed-text-v1.5" = {
              hf = "nomic-ai/nomic-embed-text-v1.5-GGUF:F32";
            };
            "zerank-1-small" = {
              hf = "mradermacher/zerank-1-small-GGUF:Q4_K_M";
            };
            # OCR
            "Nanonets-OCR-s" = {
              hf = "unsloth/Nanonets-OCR-s-GGUF:UD-Q4_K_XL";
            };
          });
          args = [
            "--host"
            "127.0.0.1"
            "--port"
            "8080"
            "--models-preset"
            "${preset}"
          ];
        in
        "${pkgs.llama-cpp-unstable}/bin/llama-server ${utils.escapeSystemdExecArgs args}";
      Restart = "on-failure";
      RestartSec = 300;

      # for GPU acceleration
      PrivateDevices = false;

      # hardening
      DynamicUser = true;
      CapabilityBoundingSet = "";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
      NoNewPrivileges = true;
      PrivateMounts = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = "strict";
      MemoryDenyWriteExecute = true;
      LockPersonality = true;
      RemoveIPC = true;
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
      ];
      SystemCallErrorNumber = "EPERM";
      ProtectProc = "invisible";
      ProtectHostname = true;
      ProcSubset = "pid";
    };
  };
  environment.etc."systemd/system-sleep/suspend-llama.sh".source = pkgs.writeShellScriptBin "suspend-llama.sh" ''
    #!/bin/sh

    case "$1" in
        pre)
            systemctl stop llama-cpp.service
            ;;
        post)
            systemctl start llama-cpp.service
            ;;
    esac
  '';
  environment.systemPackages = assert !(lib.hasAttr "stable-diffusion-cpp" pkgs); with pkgs;
    [
      aicommits
      claude-code-best
      llama-cpp-unstable
      (pkgs.callPackage "${inputs.nixpkgs-unstable}/pkgs/by-name/ch/cherry-studio/package.nix" {
        pnpm_10_29_2 = pkgs.pnpm;
      })
      (pkgs.callPackage "${inputs.nixpkgs-unstable}/pkgs/by-name/st/stable-diffusion-cpp/package.nix" {
        vulkanSupport = true;
        stdenv = ccacheStdenv;
      })
    ];
}
