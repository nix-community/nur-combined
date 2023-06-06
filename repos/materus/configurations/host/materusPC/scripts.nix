{ config, pkgs, lib, inputs, materusFlake, ... }:
let
valkyrie-sync = pkgs.writeShellScriptBin "valkyrie-sync" ''
${pkgs.rsync}/bin/rsync -avzrh --delete --exclude ".git*" --exclude "flake.lock" /materus/config/Nixerus materus@valkyrie:/materus/config/ && \
  ${pkgs.rsync}/bin/rsync -avzrh --delete --exclude ".git*" /materus/config/valkyrie materus@valkyrie:/materus/config/
'';

valkyrie-flakelock = pkgs.writeShellScriptBin "valkyrie-flakelock" ''
${pkgs.openssh}/bin/ssh materus@valkyrie "nix flake update /materus/config/Nixerus --override-input nixpkgs github:NixOS/nixpkgs/23.05 \
  --override-input home-manager github:nix-community/home-manager/release-23.05 \
  --override-input private /materus/config/valkyrie/flake"
'';

valkyrie-rebuild-boot = pkgs.writeShellScriptBin "valkyrie-rebuild-boot" ''
${pkgs.openssh}/bin/ssh -t materus@valkyrie "sudo nixos-rebuild boot --flake /materus/config/Nixerus#valkyrie \
  --override-input private /materus/config/valkyrie/flake"
'';
valkyrie-rebuild-switch = pkgs.writeShellScriptBin "valkyrie-rebuild-switch" ''
${pkgs.openssh}/bin/ssh -t materus@valkyrie "sudo nixos-rebuild switch --flake /materus/config/Nixerus#valkyrie \
  --override-input private /materus/config/valkyrie/flake"
'';


in
{ 
  environment.systemPackages = [
    valkyrie-rebuild-boot
    valkyrie-rebuild-switch
    valkyrie-sync
    valkyrie-flakelock
    ];
}
