{ pkgs, ... }:

{
  environment.sessionVariables.OS_CLOUD = "openstack";
  environment.systemPackages = [
    pkgs.openstack-rs
    # pkgs.openstackclient-full # slower python client
  ];
}
