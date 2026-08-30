{
  networking.firewall.allowedTCPPorts = [22];

  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.ac = {
    isNormalUser = true;
    extraGroups = ["wheel"];
  };
}
