{ config, pkgs, ... }:
let
  cfg = config.sane.programs;
in
{
  sane.programs.sane-sandboxed = {
    packageUnwrapped = pkgs.sane-sandboxed.override {
      bubblewrap = cfg.bubblewrap.package;
      firejail = cfg.firejail.package;
      landlock-sandboxer = pkgs.landlock-sandboxer.override {
        # not strictly necessary (landlock ABI is versioned), however when sandboxer version != kernel version,
        # the sandboxer may nag about one or the other wanting to be updated.
        linux = config.boot.kernelPackages.kernel;
      };
    };

    sandbox.enable = false;
  };
}
