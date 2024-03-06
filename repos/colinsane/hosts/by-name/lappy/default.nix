{ config, pkgs, ... }:
{
  imports = [
    ./fs.nix
  ];

  sane.roles.client = true;
  sane.roles.dev-machine = true;
  sane.roles.pc = true;
  sane.services.wg-home.enable = true;
  sane.services.wg-home.ip = config.sane.hosts.by-name."lappy".wg-home.ip;

  # sane.guest.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  sane.image.extraBootFiles = [ pkgs.bootpart-uefi-x86_64 ];

  sane.programs.sway.enableFor.user.colin = true;
  sane.programs."gnome.geary".config.autostart = true;
  sane.programs.signal-desktop.config.autostart = true;
  sane.programs.stepmania.enableFor.user.colin = true;

  sops.secrets.colin-passwd.neededForUsers = true;

  # default config: https://man.archlinux.org/man/snapper-configs.5
  # defaults to something like:
  #   - hourly snapshots
  #   - auto cleanup; keep the last 10 hourlies, last 10 daylies, last 10 monthlys.
  services.snapper.configs.nix = {
    # TODO: for the impermanent setup, we'd prefer to just do /nix/persist,
    # but that also requires setting up the persist dir as a subvol
    SUBVOLUME = "/nix";
    ALLOW_USERS = [ "colin" ];
  };

  # docs: https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "21.05";
}
