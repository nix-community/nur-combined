{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib) maintainers types mkIf mkMerge mkOption;
  cfg = config.defaultajAgordoj.cli;
  defaultPkgs = with pkgs; [ tree p7zip ];

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
      home.packages = defaultPkgs ++ cfg.extraPkgs;
    }
    (mkIf cfg.enableTmux (import ../../profiles/common/tmux.nix { inherit pkgs; }))
    (import ../../profiles/common/git.nix { })
    (import ../../profiles/common/gpg.nix { })
    (import ../../profiles/common/neovim.nix { inherit pkgs inputs; })
    (import ../../profiles/common/ssh.nix { inherit lib; })
  ]);

  meta.maintainers = with maintainers; [ wolfangaukang ];
}
