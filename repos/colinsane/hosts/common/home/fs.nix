{ config, lib, ... }:
{
  sane.user.persist.byStore.plaintext = [
    # TODO: some of ~/dev should be private too, but maybe not all 800+ GB of it
    # perhaps i ought to rethink how it's organized
    "dev"
    "ref"
    "use"
    "Books/local"
    "Music"

    # this is persisted simply to save on RAM. mesa_shader_cache is < 10 MB.
    # TODO: integrate with sane.programs.sandbox?
    ".cache/mesa_shader_cache"
  ];
  sane.user.persist.byStore.private = [
    "archive"
    "Pictures/albums"
    "Pictures/cat"
    "Pictures/from"
    "Pictures/Screenshots"  #< XXX: something is case-sensitive about this?
    "Pictures/Photos"
    "records"
    "tmp"

    "knowledge"
    "Videos/local"
  ];

  # convenience
  sane.user.fs = let
    persistEnabled = config.sane.persist.enable;
  in {
    ".persist/private" = lib.mkIf persistEnabled { symlink.target = config.sane.persist.stores.private.origin; };
    ".persist/plaintext" = lib.mkIf persistEnabled { symlink.target = config.sane.persist.stores.plaintext.origin; };
    ".persist/ephemeral" = lib.mkIf persistEnabled { symlink.target = config.sane.persist.stores.ephemeral.origin; };

    "nixos".symlink.target = "dev/nixos";

    "Books/servo".symlink.target = "/mnt/servo/media/Books";
    "Videos/servo".symlink.target = "/mnt/servo/media/Videos";
    "Pictures/servo-macros".symlink.target = "/mnt/servo/media/Pictures/macros";
  };
}
