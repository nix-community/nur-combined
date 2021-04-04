{ config, lib, pkgs }:

{
  options.programs.gc = {
    enable = lib.mkEnableOption "enable test/personal GC tool";

    maxAge = lib.mkOption {
      type = lib.types.str;
      default = "60d";
    };
  };

  config = lib.mkIf config.programs.gc.enable {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "gc" ''
        sudo ${config.nix.package}/bin/nix-collect-garbage --delete-older-than ${config.programs.gc.maxAge} --verbose
      '')
    ];
  };
}
