{ vaculib, ... }: {
  imports = vaculib.directoryGrabberList ./.;

  vacu.hostName = "vacu-agent-vm";
  vacu.systemKind = "minimal";

  services.openssh.enable = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.networkmanager.enable = true;

  users.users.agent = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  system.stateVersion = "25.11";

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
