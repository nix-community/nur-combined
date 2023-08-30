{ ... }:
{
  users.mutableUsers = false;

  users.users.pim = {
    isNormalUser = true;
    home = "/home/pim";
    uid = 1000;
    # make this numeric so that you can enter it in the phosh lockscreen.
    # DON'T leave this empty: not all greeters support passwordless users.
    initialPassword = "147147";
    extraGroups = [ "wheel" ];
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = true;
  };
}
