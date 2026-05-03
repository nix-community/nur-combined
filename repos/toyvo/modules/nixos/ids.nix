{ config, lib, ... }:
let
  # Custom UIDs claimed to prevent future NixOS collisions.
  # Adding them here lets the collision check catch future nixpkgs additions
  # that might claim the same numbers under a different name.
  ourUids = {
    multimedia = 349;
    bazarr = 350;
    prowlarr = 351;
    readarr = 352;
    qbittorrent = 353;
    immich = 354;
    minecraft = 355;
    vintagestory = 356;
    "open-webui" = 357;
    "protonmail-bridge" = 358;
    jellyfin = 359;
    nextcloud = 360;
    hermes = 361;
  };

  ourGids = {
    multimedia = 349;
    bazarr = 350;
    prowlarr = 351;
    readarr = 352;
    qbittorrent = 353;
    immich = 354;
    minecraft = 355;
    vintagestory = 356;
    "open-webui" = 357;
    "protonmail-bridge" = 358;
    jellyfin = 359;
    nextcloud = 360;
    hermes = 361;
  };

  # Returns an attrset of { "<number>" = [ { name; value; } ... ]; } for any
  # numeric value that appears under more than one name.
  findCollisions =
    ids:
    let
      entries = lib.mapAttrsToList (name: value: { inherit name value; }) ids;
      grouped = lib.groupBy (e: toString e.value) entries;
    in
    lib.filterAttrs (_: es: lib.length es > 1) grouped;

in
{
  ids.uids = ourUids;
  ids.gids = ourGids;

  assertions =
    let
      uidCollisions = findCollisions config.ids.uids;
      gidCollisions = findCollisions config.ids.gids;
    in
    lib.mapAttrsToList (num: entries: {
      assertion = false;
      message = "UID collision at ${num}: ${lib.concatMapStringsSep ", " (e: e.name) entries}";
    }) uidCollisions
    ++ lib.mapAttrsToList (num: entries: {
      assertion = false;
      message = "GID collision at ${num}: ${lib.concatMapStringsSep ", " (e: e.name) entries}";
    }) gidCollisions;
}
