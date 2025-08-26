{ config, pkgs, ... }:
let
  model = "/var/lib/llama-cpp/qwen2.5-coder-3b.guff";
in
{
  services.ollama = {
    enable = true;
    loadModels = [ "qwen2.5-coder:3b" ];
    environmentVariables = {
      https_proxy = config.networking.proxy.default;
    };
  };

  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp.override {
      vulkanSupport = true;
    };
    extraFlags = [
      "-ngl"
      "99"
    ];
    model = model;
  };
  systemd.services.llama-cpp = {
    environment = {
      HOME = "/var/lib/llama-cpp";
    };
    unitConfig = {
      ConditionPathExists = model;
    };
    serviceConfig = {
      StateDirectory = [ "llama-cpp" ];
      WorkingDirectory = [ "/var/lib/llama-cpp" ];
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
}
