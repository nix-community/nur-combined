{ config, lib, pkgs, ... }:
let
  cfg = config.sane.hal.aarch64;
in
{
  options = {
    sane.hal.aarch64-musl.enable = (lib.mkEnableOption "aarch64-musl-specific hardware support") // {
      default = pkgs.stdenv.hostPlatform.system == "aarch64-linux" && pkgs.stdenv.hostPlatform.isMusl;
    };
  };
  config = lib.mkIf cfg.enable {
    # disable the following non-essential programs which fail to cross compile musl -> musl
    sane.programs.evince.enableFor.user.colin = false;  #< 2026-05-27: blocked on `texlive.bin.core`
    sane.programs.exiftool.enableFor.user.colin = false;  #< 2026-05-26: blocked on perlPackages.SUPER
    sane.programs.htpasswd.enableFor = { system = false; user.colin = false; };  # blocked on apr (2026-05-24)
    sane.programs.megapixels.enableFor.user.colin = false;  #< 2026-05-26: blocked on perlPackages.SUPER
    sane.programs.megapixels-next.enableFor.user.colin = false;  #< 2026-05-26: blocked on perlPackages.SUPER
    # sane.programs.nix.packageUnwrapped = lib.mkVMOverride pkgs.nixVersions.latest;  #< 2026-05-24: `pkgsMusl.pkgsCross.aarch64-multiplatform.pkgsStatic.lixPackageSets.latest.lix` fails *at runtime*
    sane.programs."sane-scripts.tag-media".enableFor.user.colin = false;  #< 2026-05-25: blocked on `pkgsMusl.pkgsCross.aarch64-multiplatform.python3Packages.pyexiftool`
    sane.programs.subversion.enableFor = { system = false; user.colin = false; };  # blocked on apr (2026-05-24)
  };
}

