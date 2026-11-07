{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  cfg = config.nixcfg;
  # NixOS system config (absent in standalone home-manager builds). The git
  # identity tracks the hermes model; fall back to a static name where the
  # system config is unavailable.
  hermesSettings =
    if osConfig != null then (osConfig.services.hermes-agent.settings or null) else null;
  agentGitName =
    if hermesSettings != null then
      "AI Agent (${hermesSettings.model.default} via ${hermesSettings.model.provider}) for Collin Diekvoss"
    else
      "AI Agent for Collin Diekvoss";
in
{
  imports = [
    ../gui.nix
    ../shells.nix
    ../session.nix
    ../sops.nix
    ../programs/git.nix
    ../programs/editors/helix.nix
  ];

  options.nixcfg.users.agent.enable = lib.mkEnableOption "Enable ai agent profile";

  config = lib.mkIf cfg.users.agent.enable {
    programs = {
      man.package = pkgs.man;
      git = {
        enable = true;
        settings = {
          user.name = agentGitName;
          user.email = "agent@diekvoss.com";
          safe.directory = "/home/toyvo/*";
          core.editor = lib.mkForce "hx";
        };
      };
      nvf.defaultEditor = lib.mkForce false;
      helix = {
        enable = true;
        defaultEditor = true;
      };
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      fzf = {
        enable = true;
      };
    };
    home.packages = with pkgs; [
      ripgrep
      fd
      jq
      yq
      nix-output-monitor
      nix-tree
      gh
      tlrc
      procs
      dust
      sd
      hyperfine
    ];
  };
}
