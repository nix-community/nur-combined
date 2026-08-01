{ pkgs, ... }:

{
  environment.sessionVariables.OS_CLOUD = "openstack";

  environment.systemPackages = [
    pkgs.openstackclient-full
    # pkgs.openstack-rs
  ];
}
