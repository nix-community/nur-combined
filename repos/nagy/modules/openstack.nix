{ pkgs, ... }:

{
  environment.sessionVariables.OS_CLOUD = "openstack";
  environment.systemPackages = [
    pkgs.openstack-rs
  ];
}
