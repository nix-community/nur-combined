# User setup
{ ... }:
{
  users.users.blog = {
    description = "Blog Publisher";
    isNormalUser = true;
    group = "nginx";
    createHome = false; # Messes with permissions
    home = "/var/www/";
    openssh.authorizedKeys.keyFiles = [ ./ssh/drone.pub ];
  };
}
