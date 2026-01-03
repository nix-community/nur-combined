{ config, lib, ... }:
{
  # this is an installer image, created anew every time. There's no state we need to worry about messing up
  system.stateVersion = config.system.nixos.release;
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
  vacu.hostName = "vacuInstaller";
  vacu.shell.color = "red";
  vacu.systemKind = "minimal";

  vacu.packages = ''
    # keep-sorted start
    acpi
    aircrack-ng
    borgbackup
    dmidecode
    home-manager
    iio-sensor-proxy
    man
    mercurial
    nix-index
    nix-inspect
    nix-search-cli
    nmap
    nvme-cli
    rclone
    smartmontools
    tcpdump
    termscp
    # keep-sorted end
  '';
}
