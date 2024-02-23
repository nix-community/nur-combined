{ config, lib, ... }:

let
  # TODO: parameterize!
  persist-base = "/nix/persist";
  plaintext-dir = config.sane.persist.stores."plaintext".origin;
  plaintext-backing-dir = persist-base;  #< TODO: scope this!
in lib.mkIf config.sane.persist.enable {
  sane.persist.stores."plaintext" = {
    origin = lib.mkDefault "/mnt/persist/plaintext";
  };

  # TODO: scope this!
  sane.fs."${plaintext-dir}".mount.bind = plaintext-backing-dir;
}
