{
  inputs,
  lib,
  pkgs,
  ...
}:

{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  boot = {
    # Lanzaboote currently replaces the systemd-boot module.
    # This setting is usually set to true in configuration.nix
    # generated at installation time. So we force it to false
    # for now.
    loader.systemd-boot.enable = lib.mkForce false;

    lanzaboote = {
      enable = true;
      pkiBundle = lib.mkDefault "/var/lib/sbctl";
    };
  };

  # fwupd no longer honors FWUPD_EFIAPPDIR, so point it directly at the
  # EFI application signed by Lanzaboote (https://github.com/nix-community/lanzaboote/pull/640).
  services.fwupd.package = pkgs.fwupd.overrideAttrs (old: {
    mesonFlags = map (
      flag: if lib.hasPrefix "-Defi_app_location=" flag then "-Defi_app_location=/run/fwupd-efi" else flag
    ) old.mesonFlags;
  });

  environment.systemPackages = with pkgs; [
    # For debugging and troubleshooting Secure Boot.
    sbctl
  ];
}
