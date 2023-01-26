{ config, options, pkgs, lib, ... }: with lib; let
  cfg = config.boot.initrd.dsdt;
  opts = options.boot.initrd.dsdt;
  patchedAcpiTable = {
    dsdt,
    versionPre,
    versionPost,
  }: pkgs.runCommand "dsdt-s3.aml" {
    nativeBuildInputs = [ pkgs.buildPackages.acpica-tools ];
    inherit dsdt versionPre versionPost;
  } ''
    iasl -p ./dsdt -d $dsdt
    if ! grep -qF 'XS3,' dsdt.dsl; then
      echo XS3 not found in dsdt >&2
      exit 1
    fi
    if ! grep -qF "0x$versionPre" dsdt.dsl; then
      echo version 0x$versionPre not found in dsdt >&2
      exit 1
    fi
    sed -i \
      -e 's/XS3,/_S3,/' \
      -e "s/, 0x$versionPre/, 0x$versionPost/" \
      dsdt.dsl
    iasl -tc dsdt.dsl
    mv dsdt.aml $out
  '';
  acpiImage = dsdt: pkgs.runCommand "dsdt.img" {
    nativeBuildInputs = [ pkgs.buildPackages.cpio ];
    inherit dsdt;
  } ''
    install -D $dsdt kernel/firmware/acpi/dsdt.aml
    find kernel | cpio -H newc --create > $out
  '';
in {
  options.boot.initrd.dsdt = with types; {
    enable = mkEnableOption "DSDT patches";
    table = mkOption {
      type = path;
    };
    patched = mkOption {
      type = path;
    };
    image = mkOption {
      type = path;
    };
    s3 = {
      enable = mkEnableOption "DSDT S3 sleep patch";
      version = {
        pre = mkOption {
          type = str;
        };
        post = mkOption {
          type = str;
        };
      };
    };
  };
  config.boot = {
    initrd = {
      prepend = mkIf cfg.enable [ "${cfg.image}" ];
      dsdt = {
        patched = mkIf cfg.s3.enable (patchedAcpiTable {
          dsdt = cfg.table;
          versionPre = cfg.s3.version.pre;
          versionPost = cfg.s3.version.post;
        });
        image = let
          table = if opts.patched.isDefined then cfg.patched else cfg.table;
        in acpiImage table;
      };
    };
    kernelParams = mkIf (cfg.enable && cfg.s3.enable) [ "mem_sleep_default=deep" ];
  };
}
