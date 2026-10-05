{
  lib,
  config,
  vacuModules,
  ...
}:
{
  imports = [ vacuModules.vacuvmGuest ];

  vacu.systemKind = "server";

  services.openssh.enable = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  users.users.agent = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = lib.attrValues config.vacu.ssh.authorizedKeys;
  };

  vacuvmGuest.ipv6Gateway = "2602:fce8:106:10::1";

  vacu.packages = ''
    claude-code
    codex
  '';

  vacu.git.enable = true;
}
