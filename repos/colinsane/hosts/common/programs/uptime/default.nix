{ pkgs, ... }:
{
  sane.programs.uptime = {
    # `uptime` is provided by one of:
    # - busybox
    # - coreutils (nixos default)
    # - procps
    # none of them are great, but procps at least supports `uptime --since`
    packageUnwrapped = pkgs.linkBinIntoOwnPackage pkgs.procps "uptime";
  };
}
