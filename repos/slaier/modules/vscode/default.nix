{ pkgs, lib, utils, ... }:
let
  llama-cpp-vulkan = pkgs.llama-cpp-vulkan.overrideAttrs (prev: rec {
    version = "8665";

    outputs = [
      "out"
      "dev"
    ];

    src = pkgs.fetchFromGitHub {
      owner = "ggml-org";
      repo = "llama.cpp";
      tag = "b${version}";
      hash = "sha256-5rioYM989O6wXEtC3SWg7v3ZgMCSzE6/RyF6ILzY9rQ=";
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

    buildInputs = prev.buildInputs ++ [ pkgs.openssl ];

    npmRoot = "tools/server/webui";
    npmDepsHash = "sha256-DxgUDVr+kwtW55C4b89Pl+j3u2ILmACcQOvOBjKWAKQ=";
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
              n-gpu-layers = 99;
              flash-attn = "on";
              fit = "on";
              kv-unified = true;
            };
            # Coder
            "Llama-3.2-3B-Instruct" = {
              hf = "unsloth/Llama-3.2-3B-Instruct-GGUF:Q4_K_M";
            };
            "Qwen3.5-4B" = {
              hf = "unsloth/Qwen3.5-4B-GGUF:Q4_K_M";
              temperature = 0.6;
              top-p = 0.95;
              top-k = 20;
              min-p = 0.0;
              presence-penalty = 0.0;
              repeat-penalty = 1.0;
              reasoning = "off";
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
  environment.systemPackages = [ (pkgs.callPackage ./claude-code-best.nix { }) ];
}
