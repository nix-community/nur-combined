{ pkgs, lib, utils, inputs, ... }:
let
  llama-cpp-vulkan = pkgs.llama-cpp-vulkan.overrideAttrs (prev: rec {
    version = "8833";

    outputs = [
      "out"
      "dev"
    ];

    src = pkgs.fetchFromGitHub {
      owner = "ggml-org";
      repo = "llama.cpp";
      tag = "b${version}";
      hash = "sha256-5T71ts6xucoHH/1EfsmuJX+QFxtOVaY2PaAs0T/mL5c=";
      leaveDotGit = true;
      postFetch = ''
        git -C "$out" rev-parse --short HEAD > $out/COMMIT
        find "$out" -name .git -print0 | xargs -0 rm -rf
      '';
    };

    nativeBuildInputs = prev.nativeBuildInputs ++ (with pkgs; [
      installShellFiles
      nodejs
      npmHooks.npmConfigHook
    ]);

    buildInputs = prev.buildInputs ++ [ pkgs.openssl pkgs.spirv-headers ];

    npmRoot = "tools/server/webui";
    npmDepsHash = "sha256-RAFtsbBGBjteCt5yXhrmHL39rIDJMCFBETgzId2eRRk=";
    npmDeps = pkgs.fetchNpmDeps {
      name = "${prev.pname}-${version}-npm-deps";
      inherit src;
      preBuild = ''
        pushd ${npmRoot}
      '';
      hash = npmDepsHash;
    };

    preConfigure = ''
      prependToVar cmakeFlags "-DLLAMA_BUILD_COMMIT:STRING=$(cat COMMIT)"
      pushd ${npmRoot}
      npm run build
      popd
    '';

    cmakeFlags = prev.cmakeFlags ++ [
      (lib.cmakeBool "LLAMA_OPENSSL" true)
    ];
  });
in
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
              ctx-size = 32768;
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
        "${llama-cpp-vulkan}/bin/llama-server ${utils.escapeSystemdExecArgs args}";
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
  environment.systemPackages = [
    llama-cpp-vulkan
    (pkgs.callPackage "${inputs.nixpkgs-unstable}/pkgs/by-name/ch/cherry-studio/package.nix" {
      pnpm_10_29_2 = pkgs.pnpm;
    })
    (pkgs.callPackage ./aicommits.nix { })
    (pkgs.callPackage ./claude-code-best.nix { })
  ];
}
