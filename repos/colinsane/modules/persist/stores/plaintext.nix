{ config, lib, sane-lib, ... }:

let
  # TODO: parameterize!
  persist-base = "/nix/persist";
  origin = config.sane.persist.stores."plaintext".origin;
  backing = sane-lib.path.concat [ persist-base "plaintext" ];
in {
  sane.persist.stores."plaintext" = {
    origin = lib.mkDefault "/mnt/persist/plaintext";
  };

  sane.fs = lib.mkIf config.sane.persist.enable {
    "${origin}".mount.bind = backing;
    # let sane.fs know that the underlying device is an ordinary folder
    "${backing}".dir = {};
  };
}
