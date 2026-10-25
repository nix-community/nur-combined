{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixcfg;
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
          user.name = "AI Agent (${config.services.hermes-agent.settings.model.default} via ${config.services.hermes-agent.settings.model.provider}) for Collin Diekvoss";
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
