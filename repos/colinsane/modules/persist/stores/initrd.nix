# certain paths -- notable /var/log -- need to be mounted in the initrd.
# this presents a "gotcha", in that we can't run any of our "prepare $directory" scripts before mounting it.
#
# N.B.: if /var/log fails to mount, ssh in and manually create its backing dir, then reboot.
# it's that simple.
# it should get created automatically during (stage-2) boot/activation, though.
{ config, lib, ... }:
lib.mkIf config.sane.persist.enable {
  sane.persist.stores."initrd" = {
    origin = lib.mkDefault "/nix/persist/initrd";
    defaultMethod = "bind";
  };
}
