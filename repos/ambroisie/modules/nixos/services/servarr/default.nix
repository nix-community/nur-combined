# The total autonomous media delivery system.
# Relevant link [1].
#
# [1]: https://youtu.be/I26Ql-uX6AM
{ lib, ... }:
{
  imports = [
    ./autobrr.nix
    ./bazarr.nix
    ./cross-seed.nix
    ./jackett.nix
    ./nzbhydra.nix
    ./prowlarr.nix
    (import ./starr.nix "lidarr")
    (import ./starr.nix "radarr")
    (import ./starr.nix "readarr")
    (import ./starr.nix "sonarr")
  ];

  options.my.services.servarr = {
    enableAll = lib.mkEnableOption "media automation suite";
  };
}
