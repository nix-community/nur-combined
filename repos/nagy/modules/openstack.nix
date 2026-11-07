{ pkgs, ... }:

{
  # we try to move away from config files
  # environment.sessionVariables.OS_CLOUD = "openstack";

  environment.systemPackages = [
    pkgs.openstackclient-full
    # pkgs.openstack-rs
  ];
}
