{ inputs, pkgs, ... }:

let
  inherit (inputs) dotfiles;
  inherit (pkgs) ranger;

in {
  home = {
    file.".config/ranger/rc.conf".source = "${dotfiles}/config/ranger/rc.conf";
    packages = [ ranger ];
  };
}
