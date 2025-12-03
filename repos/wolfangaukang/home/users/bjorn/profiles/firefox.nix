{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  settings = import "${inputs.self}/home/users/bjorn/settings/firefox" { inherit config pkgs lib; };

in
{
  programs.firefox = {
    enable = true;
    package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
      extraPolicies = {
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
      };
    };
    profiles = settings.defaultProfiles // {
      personal = settings.profiles.personal;
      gnaujep = settings.profiles.gnaujep;
      j = settings.profiles.j;
    };
  };
}
