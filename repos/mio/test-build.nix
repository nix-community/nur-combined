let
  pkgs = import <nixpkgs> { config.allowUnfree = true; };
  nurpkgs = builtins.getFlake "git+file:///home/dev/Documents/nurpkgs2";
in
pkgs.callPackage /home/dev/Documents/config/nixos/davinci-resolve-paid.nix {
  davinci-resolve-studio = nurpkgs.packages.${pkgs.system}.davinci-resolve-studio211;
}
