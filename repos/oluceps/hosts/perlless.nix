_:

{

  # Remove perl from activation
  boot.initrd.systemd.enable = true;
  system.etc.overlay.enable = true;
  services.userborn.enable = true;

  # Random perl remnants
  system.tools.nixos-generate-config.enable = false;
  programs.less.lessopen = null;
  programs.command-not-found.enable = false;
  boot.enableContainers = false;
  boot.loader.grub.enable = false;
  environment.defaultPackages = [ ];
  documentation.info.enable = false;
  documentation.nixos.enable = false;

  # Check that the system does not contain a Nix store path that contains the
  # string "perl".
  system.forbiddenDependenciesRegexes = [ "perl" ];
}
