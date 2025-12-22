{ lib, pkgs, ... }:
let
  cachePath = "/propdata/nixcache";
in
{
  services.caddy.virtualHosts."nixcache.shelvacu.com" = {
    vacu.hsts = "preload";
    serverAliases = [ "http://local-nixcache.shelvacu.com" ];
    extraConfig = ''
      root * ${cachePath}
      file_server
    '';
  };
  vacu.nix.caches.vacu.url = lib.mkForce "file://${cachePath}?priority=5&want-mass-query=true";
  vacu.packages = [
    (pkgs.writers.writeBashBin "into-nix-cache" ''
      if [[ $UID -ne 0 ]]; then exec sudo $0 "$@";fi
      cmd=(
        ${pkgs.nix}/bin/nix
        copy
        --no-update-lock-file
        --no-write-lock-file
        --keep-going
        --to 'file://${cachePath}?parallel-compression=true&secret-key=/root/cache-priv-key.pem&want-mass-query=true&write-nar-listing=true'
        "$@"
      )
      printf "running:"
      printf " %q" "''${cmd[@]}"
      printf '\n'
      "''${cmd[@]}"
    '')
  ];
}
