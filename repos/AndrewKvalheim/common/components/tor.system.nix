{ config, lib, pkgs, ... }:

let
  inherit (builtins) length;
  inherit (config) host;
  inherit (lib) getExe mkIf mkMerge mkOption;
  inherit (lib.types) listOf str;
  inherit (pkgs) obfs4;
in
{
  options.host.tor = {
    bridges = mkOption { type = listOf str; };
  };

  config = {
    services.tor = {
      enable = true;
      client.enable = true;

      settings = mkMerge [
        {
          CacheDirectory = "/var/cache/tor"; # TODO: Upstream
        }
        (mkIf (length host.tor.bridges > 0) {
          Bridge = host.tor.bridges;
          ClientTransportPlugin = "obfs4 exec ${getExe obfs4}";
          UseBridges = true;
        })
      ];
    };

    systemd.services.tor = {
      onFailure = [ "alert@%N.service" ];

      serviceConfig = {
        CacheDirectory = "%N"; # Used by services.tor.settings.CacheDirectory
        CacheDirectoryMode = "0700";
      };
    };
  };
}
