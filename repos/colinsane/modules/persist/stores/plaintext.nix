{ config, lib, ... }:

let
  cfg = config.sane.persist;
in lib.mkIf cfg.enable {
  sane.persist.stores."plaintext" = lib.mkDefault {
    origin = "/nix/persist";
  };
  # TODO: needed?
  # sane.fs."/nix".mount = {};
}
