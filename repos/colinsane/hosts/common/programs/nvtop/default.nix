# nvtop is multi-vendor (amd, intel, etc) despite its name
{ pkgs, ... }:
{
  sane.programs.nvtop = {
    packageUnwrapped = pkgs.nvtopPackages.full.override {
      nvidia = false;  #< cuda_compat fails to build
    };
    sandbox.keepPidsAndProc = true;
    sandbox.tryKeepUsers = true;
    sandbox.capabilities = [
      "cap_dac_read_search"
      "cap_sys_ptrace"
    ];
    sandbox.extraPaths = [
      "/dev/dri"
      "/sys/dev/char"
      "/sys/devices"
    ];
  };
}
