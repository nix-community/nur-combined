{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.eownerdead.dev.cpp.enable =
    lib.mkEnableOption "Enable C/C++ develop tools";

  config = lib.mkIf config.eownerdead.dev.cpp.enable {
    home.packages = with pkgs; [
      gnumake
      clang
      clang-tools
      gdb
      lldb
      valgrind
      mold
    ];
  };
}
