{ config, ... }:
{
  security.pam = {
    u2f = {
      enable = true;
      settings.authfile = config.vaultix.secrets.pam.path;
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
