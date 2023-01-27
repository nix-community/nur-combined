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
    enable = mkEnableOption "DSDT patches" // {
      default = cfg.patch.enable;
    };
    table = mkOption {
      type = path;
    };
    version = mkOption {
      type = strMatching "[0-9a-f]+";
    };
    image = mkOption {
      type = path;
      default = acpiImage cfg.table;
      defaultText = "mkAcpiImage config.boot.initrd.dsdt.table";
    };
    patch = {
      enable = mkEnableOption "DSDT patches" // {
        default = cfg.patch.s3.enable;
      };
      table = mkOption {
        type = path;
      };
      version = mkOption {
        type = strMatching "[0-9a-f]+";
      };
      s3.enable = mkEnableOption "DSDT S3 sleep patch";
    };
  };
  config.boot = {
    initrd = {
      prepend = mkIf cfg.enable [ "${cfg.image}" ];
      dsdt = {
        table = let
          patched = patchedAcpiTable {
            dsdt = cfg.patch.table;
            versionPre = cfg.patch.version;
            versionPost = cfg.version;
          };
        in mkIf cfg.patch.enable (mkOptionDefault patched);
      };
    };
    kernelParams = mkIf (cfg.enable && cfg.patch.enable && cfg.patch.s3.enable) [
      "mem_sleep_default=deep"
    ];
  };
}
