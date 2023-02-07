{ config, lib, ... }:
with lib;
let
  cfg = config.my.users;
  user = import ./user.nix;
  vscodeInBase = builtins.hasAttr "vscode" config.my;

  programs = builtins.foldl' (x: y: x // y) { } ([ ] ++ (if vscodeInBase then
    [ (import ../../modules/vscode/generator.nix { inherit config user; }) ]
  else
    [ ]));
in {
  options.my = {
    users = mkOption {
      type = with types; attrsOf (submodule user);
      default = { };
      description = ''
        User accounts to create on the local system.
      '';
    };
  };

  config = mkIf (config.my.users != { }) {
    users.users = builtins.mapAttrs (key: value: value) config.my.users;
    home-manager.users = builtins.mapAttrs (user: value: {
      xdg.configFile."nix/inputs/nixpkgs".source =
        config.my.flake.inputs.nixpkgs.outPath;
      home.sessionVariables.NIX_PATH =
        "nixpkgs=${value.home}/.config/nix/inputs/nixpkgs\${NIX_PATH:+:$NIX_PATH}";

      inherit programs;
    }) config.my.users;
  };
}
