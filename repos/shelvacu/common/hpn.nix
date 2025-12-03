{
  config,
  lib,
  vacuModuleType,
  ...
}:
{
  # options.vacu.ssh-hpn.enable = lib.mkEnableOption "openssh hpn";
}
// lib.optionalAttrs (vacuModuleType == "nixos") {
  # config.nixpkgs.overlays = [ (old: new: {
  #   openssh-without-hpn = old.openssh;
  #   openssh = if config.vacu.ssh-hpn.enable then new.openssh_hpn else new.openssh-without-hpn;
  # }) ];
}
