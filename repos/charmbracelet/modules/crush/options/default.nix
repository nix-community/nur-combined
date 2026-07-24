{ pkgs }:

let
  inherit (pkgs) lib;
in
{
  programs.crush = {
    enable = lib.mkEnableOption "Enable crush";

    package = lib.mkOption {
      default = (import ../../../pkgs { inherit pkgs; }).crush;
      defaultText = lib.literalExpression "charmbracelet-nur.pkgs.crush";
      description = "Package to use for crush";
    };

    settings = import ./settings.nix { inherit lib; };
  };
}
