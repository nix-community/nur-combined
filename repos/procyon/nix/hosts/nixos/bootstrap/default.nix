# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

{ flake, config, pkgs, lib, ... }:
let
  home = lib.attrsets.mapAttrsToList (n: v: v.activationPackage) flake.inputs.self.homeConfigurations;
  host = lib.attrsets.mapAttrsToList (n: v: v.config.system.build.toplevel) flake.inputs.self.nixosConfigurations;
in
{
  imports = [
    flake.inputs.nixos-generators.nixosModules.install-iso
    "${flake.inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = lib.mkImageMediaOverride "procyon-installer";

  boot.swraid.mdadmConf = ''
    MAILADDR=disable@nix.warning
  '';

  isoImage = {
    storeContents = home ++ host;
    volumeID = "procyon-${config.system.nixos.release}-${flake.self.shortRev or "dirty"}-${pkgs.stdenv.hostPlatform.uname.processor}";
    isoName = lib.mkImageMediaOverride "procyon-${config.system.nixos.release}-${flake.self.shortRev or "dirty"}-${pkgs.stdenv.hostPlatform.uname.processor}.iso";
  };
}
