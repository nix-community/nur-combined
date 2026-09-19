{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.darling;
in
{
  options = {
    programs.darling = {
      enable = lib.mkEnableOption "Darling, a Darwin/macOS compatibility layer for Linux";
      package = lib.mkPackageOption pkgs "darling" { };
    };
  };

  config = lib.mkIf cfg.enable {
    # Required for bootstrap: Yama blocks darlingserver's process_vm_readv on mldr
    # when ptrace_scope>=1; Mach-O loads need mmap_min_addr=0.
    boot.kernel.sysctl = {
      "kernel.yama.ptrace_scope" = 0;
      "vm.mmap_min_addr" = 0;
    };

    security.wrappers.darling = {
      source = lib.getExe cfg.package;
      owner = "root";
      group = "root";
      setuid = true;
    };
  };
}
