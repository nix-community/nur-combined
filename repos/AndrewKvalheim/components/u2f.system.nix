{ config, ... }:

let
  inherit (config) host;
in
{
  security.pam.u2f = {
    enable = true;

    control = "sufficient";

    settings = {
      appid = "pam://${host.name}";
      authfile = "/etc/u2f-mappings";
      cue = true;
    };
  };
}
