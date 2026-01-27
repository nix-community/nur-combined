{ pkgs, ... }:
{
  projectRootFile = "flake.nix";
  programs.nixfmt = {
    enable = true;
    package = pkgs.nixfmt-rfc-style;
  };
  programs.taplo.enable = true;
}
