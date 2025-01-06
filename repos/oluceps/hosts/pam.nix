{ config, user, ... }:
{
  vaultix.templates.pam-authfile = {
    content = user + config.vaultix.placeholder.pam;
    owner = user;
  };
  security.pam = {
    u2f = {
      enable = true;
      settings.authfile = config.vaultix.templates.pam-authfile.path;
      settings.cue = true;
      control = "sufficient";
    };
    services = {
      sudo.u2fAuth = true;
      login.u2fAuth = true;
    };
    loginLimits = [
      {
        domain = "*";
        type = "-";
        item = "memlock";
        value = "unlimited";
      }
    ];
  };
}
