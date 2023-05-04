{ config, pkgs, ... }:

{
  imports = [
    ./fs.nix
    ./net.nix
    ./secrets.nix
    ./services
  ];

  sane.programs = {
    # for administering services
    freshrss.enableFor.user.colin = true;
    matrix-synapse.enableFor.user.colin = true;
    signaldctl.enableFor.user.colin = true;
  };

  sane.roles.build-machine.enable = true;
  sane.roles.build-machine.emulation = false;
  sane.zsh.showDeadlines = false;  # ~/knowledge doesn't always exist
  sane.services.dyn-dns.enable = true;
  sane.services.wg-home.enable = true;
  sane.services.wg-home.ip = config.sane.hosts.by-name."servo".wg-home.ip;
  # sane.services.duplicity.enable = true;  # TODO: re-enable after HW upgrade

  # automatically log in at the virtual consoles.
  # using root here makes sure we always have an escape hatch
  services.getty.autologinUser = "root";

  boot.loader.efi.canTouchEfiVariables = false;
  sane.image.extraBootFiles = [ pkgs.bootpart-uefi-x86_64 ];

  # both transmission and ipfs try to set different net defaults.
  # we just use the most aggressive of the two here:
  boot.kernel.sysctl = {
    "net.core.rmem_max" = 4194304;  # 4MB
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11";
}

