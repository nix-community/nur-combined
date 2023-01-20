{ config, lib, pkgs, ... }:

let
  inherit (lib) maintainers types mkIf mkMerge mkOption;
  cfg = config.defaultajAgordoj.cli;
  settings = import ./settings.nix { inherit pkgs; };

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
  };

  config = mkIf cfg.enable (mkMerge [
    { home.packages = settings.packages.cli; }
    (import ../../profiles/common/git.nix { })
    (import ../../profiles/common/gpg.nix { })
    (import ../../profiles/common/neovim.nix { inherit pkgs; })
    (import ../../profiles/common/ssh.nix { inherit lib; })
  ]);

  meta.maintainers = with maintainers; [ wolfangaukang ];
}
