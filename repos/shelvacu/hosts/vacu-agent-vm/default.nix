{ lib, config, vaculib, vacuModules, ... }:
{
  imports = [
    vacuModules.vacuvmGuest
  ] ++ vaculib.directoryGrabberList ./.;

  vacu.hostName = "vacu-agent-vm";

  services.openssh.enable = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  users.users.agent = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = lib.attrValues config.vacu.ssh.authorizedKeys;
  };

  system.stateVersion = "25.11";

  vacuvmGuest.ip = "10.78.77.2";

  networking.firewall.allowedUDPPorts = [
    137
    138
  ];
  networking.firewall.allowedTCPPorts = [
    139
    445
  ];

  vacu.packages = ''
    claude-code
    codex
  '';

  vacu.git.enable = true;
}
