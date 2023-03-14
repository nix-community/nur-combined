{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib) maintainers types mkIf mkMerge mkOption;
  inherit (inputs) self;
  cfg = config.defaultajAgordoj.cli;

in
{
  options.defaultajAgordoj.cli = {
    enable = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Enables the CLI tools, plus the common Git, GPG, Neovim, Pass and SSH settings.
      '';
    };
    enableTmux = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Enables TMUX.
      '';
    };
    extraPkgs = mkOption {
      default = [ ];
      type = types.listOf types.package;
      description = ''
        List of extra packages to install
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = cfg.extraPkgs;
    }
    (mkIf cfg.enableTmux (import "${self}/home/profiles/programs/tmux.nix" { inherit pkgs; }))
    (import "${self}/home/profiles/programs/git.nix" { })
    (import "${self}/home/profiles/programs/gpg.nix" { })
    (import "${self}/home/profiles/programs/neovim.nix" { inherit pkgs inputs; })
    (import "${self}/home/profiles/programs/ssh.nix" { inherit lib; })
  ]);

  meta.maintainers = with maintainers; [ wolfangaukang ];
}
