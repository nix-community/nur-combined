{
  inputs,
  ...
}:
{
  imports = [
    inputs.srvos.nixosModules.server
    "${inputs.nixpkgs}/nixos/modules/virtualisation/google-compute-image.nix"
  ];
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];

  documentation.man.enable = false;
  services.cloud-init.enable = true;

  # google-compute-image.nix only creates a /boot partition when EFI
  # booting is enabled (it isn't here), so /boot lives on the root
  # partition — nix-mineral's separate-partition hardening doesn't apply.
  nix-mineral.enable = false;
  system.stateVersion = "26.05";
}
