{
  lib,
  pkgs,
  userKeys,
  ...
}:

{
  virtualisation.vmVariant = import ./vm.nix;

  users.users = {
    iamanaws.openssh.authorizedKeys.keys = [ userKeys.archimedes.iamanaws ];
  };

  environment.systemPackages = with pkgs; [
    vim
  ];

  networking = {
    # override core defaults
    networkmanager.enable = lib.mkForce false;
    # Open firewall ports for DNS
    firewall.allowedUDPPorts = [
      53
      67
      68
    ];
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  services = {
    getty.autologinUser = lib.mkForce "iamanaws";
    openssh.enable = true;
    timesyncd.enable = lib.mkDefault true;
  };

  zramSwap.enable = true;

}
