{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nagy.zig;
in
{
  imports = [ ./shortcommands.nix ];

  options.nagy.zig = {
    enable = lib.mkEnableOption "zig config";
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [
      pkgs.zig
      pkgs.zls
    ];

    nagy.shortcommands = {
      zb = [
        "zig"
        "build"
      ];
      zbs = [
        "zig"
        "build"
        "-Doptimize=ReleaseSmall"
      ];
      zbe = [
        "zig"
        "build-exe"
      ];
      zbes = [
        "zig"
        "build-exe"
        "-Doptimize=ReleaseSmall"
      ];
      zbr = [
        "zig"
        "build"
        "run"
      ];
      zbt = [
        "zig"
        "build"
        "test"
      ];
    };
  };
}
