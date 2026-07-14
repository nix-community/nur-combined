{ localFlake, withSystem }:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.edk2-cix;

  productDir = "${cfg.package}/edk2/radxa/${cfg.product}";

  # Install everything under edk2/radxa/<product>/ instead of hand-listing
  # filenames, so this doesn't go stale when upstream adds/removes a file.
  # startup.nsh is excluded here since it needs patching (see below).
  productFileNames = builtins.attrNames (
    lib.filterAttrs (name: type: type == "regular" && name != "startup.nsh") (
      builtins.readDir productDir
    )
  );

  productStartupNsh = pkgs.runCommand "edk2-cix-${cfg.product}-startup.nsh" { } ''
    sed 's/set product ./set product " for ${cfg.product}."/' \
      ${productDir}/startup.nsh > "$out"
  '';
in
{
  options.services.edk2-cix = {
    enable = lib.mkEnableOption ''
      installing Radxa's prebuilt CIX EDK II (UEFI) firmware for one board
      and a systemd-boot entry to flash it

      Declarative equivalent of upstream's debian/edk2-cix.postinst
      (radxa-pkg/edk2-cix), via `boot.loader.systemd-boot.extraFiles`/
      `extraEntries`. Unlike upstream, only the board set in
      {option}`services.edk2-cix.product` is installed, and its flashing
      entry is enabled directly rather than left as `*.conf.disabled`:
      selecting it in the boot menu immediately flashes `cix_flash_all.bin`,
      with no separate step to enable a disabled entry first
    '';

    product = lib.mkOption {
      type = lib.types.str;
      description = ''
        Which board's EDK2 firmware to install and enable a flashing entry
        for. Must match the name of a directory under `edk2/radxa/` in the
        edk2-cix package (e.g. "orion-o6n") -- the actual hardware this
        configuration is deployed to. Flashing the wrong board's image will
        very likely brick it.
      '';
      example = "orion-o6n";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = withSystem pkgs.stdenv.hostPlatform.system ({ config, ... }: config.packages.edk2-cix);
      defaultText = lib.literalMD "`packages.edk2-cix` from the shirok1/flakes flake";
      description = "The edk2-cix package providing the firmware images.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.boot.loader.systemd-boot.enable;
        message = "services.edk2-cix installs a systemd-boot style loader entry and requires boot.loader.systemd-boot.enable.";
      }
    ];

    boot.loader.systemd-boot.extraFiles =
      lib.listToAttrs (
        map (f: {
          name = "edk2/radxa/${cfg.product}/${f}";
          value = "${productDir}/${f}";
        }) productFileNames
      )
      // {
        "edk2/radxa/${cfg.product}/startup.nsh" = productStartupNsh;
      };

    boot.loader.systemd-boot.extraEntries."edk2-${cfg.product}.conf" = ''
      title           Install EDK2 ${cfg.package.version} for ${cfg.product}
      version         ${cfg.package.version}
      efi             /edk2/radxa/${cfg.product}/Shell.efi
      architecture    aa64
    '';
  };
}
