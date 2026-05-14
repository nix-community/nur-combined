{ pkgs, lib, utils, inputs, ... }:
{
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
              sleep-idle-seconds = 600;
              n-gpu-layers = 99;
              flash-attn = "on";
              fit = "on";
              fit-target = 512;
              prio = 3;
              kv-unified = true;
              ctx-size = 16384;
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
              ot = ''blk\.[1-2]?[0-9]\.ffn_.*exps.*=CPU'';
              ctk = "q8_0";
              ctv = "q8_0";
              no-mmap = true;
            };
            "Jan-v3-4B-base-instruct" = {
              hf = "janhq/Jan-v3-4B-base-instruct-gguf";
              temperature = 0.7;
              top-p = 0.8;
              top-k = 20;
              min-p = 0;
              presence-penalty = 1.5;
              repeat-penalty = 1.0;
              ctx-size = 49152;
              ctk = "q8_0";
              ctv = "q8_0";
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
            "--models-max"
            "1"
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
  environment.systemPackages = with pkgs; [
    aicommits
    claude-code-best
    llama-cpp-unstable
    (pkgs.callPackage "${inputs.nixpkgs-unstable}/pkgs/by-name/ch/cherry-studio/package.nix" {
      pnpm_10_29_2 = pkgs.pnpm;
    })
    (pkgs.callPackage "${inputs.nixpkgs-unstable}/pkgs/by-name/st/stable-diffusion-cpp/package.nix" {
      vulkanSupport = true;
    })
  ];
}
