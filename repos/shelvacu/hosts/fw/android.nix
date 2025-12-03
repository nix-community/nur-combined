{ pkgs, ... }:
{
  vacu.packages = pkgs.androidStudioPackages.stable.all;
  users.users.shelvacu.extraGroups = [ "kvm" ];
}
