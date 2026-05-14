{ config, lib, ... }:

let
  inherit (config) host;
  inherit (lib) mkIf;
in
mkIf host.features.llm {
  nixpkgs.config.rocmSupport = true;
}
