{ config, pkgs, ... }:

let
  llmAgentsPkgs = (builtins.getFlake "github:numtide/llm-agents.nix").packages.x86_64-linux;
in
{

  environment.systemPackages = [
    llmAgentsPkgs.pi
    llmAgentsPkgs.omp
  ];

  environment.sessionVariables = {
    PI_TELEMTRY = "0";
    PI_OFFLINE = "1";
    PI_SKIP_VERSION_CHECK = "1";
    PONYTAIL_DEFAULT_MODE = "off";
  };

}
