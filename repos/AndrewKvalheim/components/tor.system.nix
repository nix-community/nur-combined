{ config, lib, pkgs, ... }:

let
  inherit (builtins) length;
  inherit (config) host;
  inherit (lib) getExe mkMerge mkOption optionalAttrs;
  inherit (lib.types) listOf str;
  inherit (pkgs) obfs4;

  lyrebird = obfs4; # Pending rename of package
in
{
  options.host.tor = {
    bridge-transport = mkOption { type = str; default = "obfs4"; };
    bridges = mkOption { type = listOf str; };
  };

  config = mkMerge [
    # Pending NixOS/nixpkgs#474615
    {
      services.tor.settings.CacheDirectory = "/var/cache/tor";
      systemd.services.tor.serviceConfig = {
        CacheDirectory = "%N";
        CacheDirectoryMode = "0700";
      };
    }

    {
      services.tor = {
        enable = true;
        client.enable = true;

        settings = optionalAttrs (length host.tor.bridges > 0) {
          Bridge = host.tor.bridges;
          ClientTransportPlugin = "${host.tor.bridge-transport} exec ${getExe lyrebird}";
          UseBridges = true;
        };
      };

      systemd.services.tor = {
        onFailure = [ "alert@%N.service" ];
        restrictExecToNixStore = true;
      };
    }
  ];
}
