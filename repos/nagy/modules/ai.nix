{ config, pkgs, ... }:

let
  self = import ../. { inherit pkgs; };
  llmAgentsPkgs = (builtins.getFlake "github:numtide/llm-agents.nix").packages.x86_64-linux;
in
{

  environment.systemPackages = [
    llmAgentsPkgs.pi
    llmAgentsPkgs.omp

    pkgs.llama-cpp-vulkan
    # pkgs.aichat
    self.llm-ttok
  ];

  environment.sessionVariables = {
    PI_TELEMETRY = "0";
    PI_OFFLINE = "1";
    PI_SKIP_VERSION_CHECK = "1";
    PONYTAIL_DEFAULT_MODE = "off";
  };

}
