{ config, lib, ... }:
{
  sane.user.persist.byStore.plaintext = [
    "archive"
    "dev"
    # TODO: records should be private
    "records"
    "ref"
    "tmp"
    "use"
    "Books/local"
    "Music"
    "Pictures/albums"
    "Pictures/cat"
    "Pictures/from"
    "Pictures/Screenshots"  #< XXX: something is case-sensitive about this?
    "Pictures/Photos"
    "Videos/local"

    # these are persisted simply to save on RAM.
    # ~/.cache/nix can become several GB.
    # mesa_shader_cache is < 10 MB.
    # TODO: integrate with sane.programs.sandbox?
    ".cache/mesa_shader_cache"
    ".cache/nix"
  ];
  sane.user.persist.byStore.private = [
    "knowledge"
  ];

  # convenience
  sane.user.fs = let
    persistEnabled = config.sane.persist.enable;
  in {
    ".persist/private" = lib.mkIf persistEnabled { symlink.target = config.sane.persist.stores.private.origin; };
    ".persist/plaintext" = lib.mkIf persistEnabled { symlink.target = config.sane.persist.stores.plaintext.origin; };
    ".persist/ephemeral" = lib.mkIf persistEnabled { symlink.target = config.sane.persist.stores.cryptClearOnBoot.origin; };

    "nixos".symlink.target = "dev/nixos";

    "Books/servo".symlink.target = "/mnt/servo/media/Books";
    "Videos/servo".symlink.target = "/mnt/servo/media/Videos";
    "Pictures/servo-macros".symlink.target = "/mnt/servo/media/Pictures/macros";
  };
}
