{ config, ... }:
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
  sane.user.fs.".persist/private".symlink.target = config.sane.persist.stores.private.origin;
  sane.user.fs.".persist/plaintext".symlink.target = config.sane.persist.stores.plaintext.origin;
  sane.user.fs.".persist/ephemeral".symlink.target = config.sane.persist.stores.cryptClearOnBoot.origin;

  sane.user.fs."nixos".symlink.target = "dev/nixos";

  sane.user.fs."Books/servo".symlink.target = "/mnt/servo/media/Books";
  sane.user.fs."Videos/servo".symlink.target = "/mnt/servo/media/Videos";
  # sane.user.fs."Music/servo".symlink.target = "/mnt/servo/media/Music";
  sane.user.fs."Pictures/servo-macros".symlink.target = "/mnt/servo/media/Pictures/macros";
}
