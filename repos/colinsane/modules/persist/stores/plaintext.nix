{ config, lib, ... }:

let
  # TODO: parameterize!
  persist-base = "/nix/persist";
  origin = config.sane.persist.stores."plaintext".origin;
  backing = persist-base;  #< TODO: scope this!
in {
  sane.persist.stores."plaintext" = {
    origin = lib.mkDefault "/mnt/persist/plaintext";
  };

  # TODO: scope this!
  sane.fs = lib.mkIf config.sane.persist.enable {
    "${origin}".mount.bind = backing;
  };
}
