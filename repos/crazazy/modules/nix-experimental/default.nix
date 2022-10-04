{ config, lib, pkgs, ... }:
let
  sources = import ../../nix/default.nix;
  flakeJSON = pkgs.runCommand { buildInputs = with pkgs; [ jq ]; } ''
    cat ${../../nix/sources.json} | jq 'to_entries|map(.value)|map(select(.flake))|map({from:{id:.repo,type:"indirect"},to:{owner:.owner,repo:.repo,branch:.branch,type:"github"}}) > $out'
  '';
in
{
  options.nixExperimental.enable = lib.mkEnableOption "whether to set up the experimental version of nix";
  config = lib.mkIf config.nixExperimental.enable {
    nix = {
      package = pkgs.nixVersions.stable;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      registry = lib.mapAttrs (k: v: { flake = v; }) (import sources.flake-compat { src = ../..; }).defaultNix.inputs;
      # registry = buildInputs.fromJSON flakeJSON;
    };
  };
}
