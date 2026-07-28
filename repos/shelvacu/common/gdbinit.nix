{ lib, vacuModuleType, ... }:
lib.optionalAttrs (vacuModuleType == "nixos" || vacuModuleType == "nix-on-droid") {
  environment.etc."gdb/gdbinit.d/vacu.gdb".text = ''
    #from https://stackoverflow.com/a/17975687/1267729
    define hook-quit
      set confirm off
    end
  '';
}
