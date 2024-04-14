# gvfs is used by e.g. nautilus to mount remote filesystems (ftp://, etc)
# TODO: gvfs depends on udisks, depends on gnupg,
# and as part of this `keyboxd` gpg daemon gets started and does background work every minute even though i totally don't use it.
{ config, pkgs, ... }:
let
  cfg = config.sane.programs.gvfs;
in
{
  sane.programs.gvfs = {
    packageUnwrapped = pkgs.gvfs.override {
      # i don't need to mount samba shares, and samba build is expensive/flaky (mostly for cross, but even problematic on native)
      samba = null;
    };
  };

  services.gvfs = {
    inherit (cfg) package;
    enable = cfg.enabled;
  };
}
