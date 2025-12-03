{ config, lib, ... }:
{
  # this is an installer image, created anew every time. There's no state we need to worry about messing up
  system.stateVersion = config.system.nixos.release;
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
  vacu.hostName = "vacuInstaller";
  vacu.shell.color = "red";
  vacu.systemKind = "minimal";

  vacu.packages = ''
    acpi
    iio-sensor-proxy
    aircrack-ng
    # bitwarden-cli # 800MB closure size!
    borgbackup
    dmidecode
    home-manager
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
  '';
}
