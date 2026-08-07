{ lib, config, vaculib, vacuModules, ... }:
{
  imports = [
    vacuModules.vacuvmGuest
  ] ++ vaculib.directoryGrabberList ./.;

  vacu.hostName = "savm";

  services.openssh.enable = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  users.users.agent = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = lib.attrValues config.vacu.ssh.authorizedKeys;
  };

  system.stateVersion = "26.05";

  vacuvmGuest.ip = "10.78.77.4";

  vacu.packages = ''
    claude-code
    codex
  '';

  vacu.git.enable = true;
}
