{ pkgs, config, lib, ... }: with lib; let
  inherit (pkgs) hostPlatform;
  inherit (config.boot.kernelPackages) kernel;
  cfg = config.boot.kernel;
  arc = import ../../canon.nix { inherit pkgs; };
  linuxPackages_bleeding = pkgs.linuxPackages_bleeding or arc.build.linuxPackages_bleeding;
  more_uarches = pkgs.kernelPatches.more_uarches or arc.packages.kernelPatches.more_uarches;
  isGcc11 = kernel.stdenv.cc.isGNU && versionAtLeast kernel.stdenv.cc.version "11.1";
  defaultArch = if hostPlatform.config == "x86_64-unknown-linux-gnu" && isGcc11 then "x86-64-v2" else null;
in {
  options.boot.kernel = {
    customBuild = mkOption {
      type = types.bool;
      default = false;
    };
    bleedingEdge = mkOption {
      type = types.bool;
      default = false;
    };
    arch = mkOption {
      type = with types; nullOr str;
      default = hostPlatform.linux-kernel.arch or hostPlatform.gcc.arch or defaultArch;
    };
    extraPatches = mkOption {
      type = with types; listOf attrs;
      default = [ ];
    };
  };

  config.boot = {
    kernel = {
      extraPatches = mkIf (hostPlatform.isx86 && cfg.arch != null) [ (more_uarches.override {
        linux = config.boot.kernelPackages.kernel;
        gccArch = cfg.arch;
      }) ];
    };
    kernelPackages = mkIf cfg.bleedingEdge linuxPackages_bleeding;
    kernelPatches = mkIf cfg.customBuild cfg.extraPatches;
  };
}
