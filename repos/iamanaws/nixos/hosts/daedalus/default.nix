{
  config,
  lib,
  flakeRoot,
  nixosModules,
  userKeys,
  ...
}:

let
  secrets = flakeRoot + /secrets/daedalus;
in

{
  imports = [
    secrets
  ]
  ++ (with nixosModules; [
    hardened
    programs.lanzaboote
    services.auto-upgrade
  ]);

  # To do on the machine:
  # - Unattended LUKS unlock (TPM2 or initrd SSH), then allow reboots again.
  # - Notify someone when nixos-upgrade.service fails.
  # - Confirm the password secret decrypts at boot: `journalctl -b | grep sops`.

  # Upgrades are staged for the next boot. Nobody can unlock the disk after an
  # unattended reboot, so reboot by hand.
  system.autoUpgrade.allowReboot = false;

  # Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    iamanaws = {
      hashedPasswordFile = config.sops.secrets.passwd.path;
      openssh.authorizedKeys.keys = [ userKeys.archimedes.iamanaws ];
    };
  };

  services = {
    getty.autologinUser = lib.mkForce "iamanaws";
  };

}
