# TODO (doc) CacheKeys format reference link
/*
  A module that configures an agent machine to use caches for reading and/or
  writing.
 */
{ pkgs, lib, config, ... }:
let
  cfg = config.services.hercules-ci-agent;
  inherit (cfg.finalConfig) binaryCachesPath;

  inherit (lib.lists) filter concatMap concatLists;
  inherit (lib) types isAttrs mkIf escapeShellArg attrValues mapAttrsToList filterAttrs;
  inherit (builtins) readFile fromJSON map split;

  allBinaryCaches =
    if cfg.binaryCachesFile == null
    then {}
    else builtins.fromJSON (builtins.readFile cfg.binaryCachesFile);

  cachixCaches =
    filterAttrs (k: v: (v.kind or null) == "CachixCache") allBinaryCaches;

  cachixVersionWarnings =
    mapAttrsToList (k: v: "In file ${toString cfg.binaryCachesFile}, entry ${k}, unsupported CachixCache version ${(v.apiVersion or null)}")
      (filterAttrs (k: v: (v.apiVersion or null) != null) cachixCaches);

  otherCaches =
    filterAttrs (k: v: (v.kind or null) != "CachixCache") allBinaryCaches;
  otherCachesWarnings =
    mapAttrsToList (k: v: "In file ${toString cfg.binaryCachesFile}, entry ${k}, unsupported cache with kind ${(v.kind or null)}") otherCaches;

in
{
  config = mkIf (cfg.enable && cfg.binaryCachesFile != null) {

    warnings = otherCachesWarnings ++ cachixVersionWarnings;

    nix.trustedBinaryCaches = [ "https://cache.nixos.org/" ] ++ mapAttrsToList (name: keys: "https://${name}.cachix.org") cachixCaches;
    nix.binaryCachePublicKeys = concatLists (mapAttrsToList (name: keys: keys.publicKeys) cachixCaches);

    # This netrc file needs to be installed by system-caches.PLATFORM.nix
    nix.extraOptions = ''
      netrc-file = /etc/nix/daemon-netrc
    '';

  };
}
