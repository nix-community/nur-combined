{ config, pkgs, ... }:

{

  environment.systemPackages = [
    pkgs.pi-coding-agent
  ];

  environment.sessionVariables = {
    PI_TELEMTRY = "0";
    PI_OFFLINE = "1";
    PI_SKIP_VERSION_CHECK = "1";
  };

}
