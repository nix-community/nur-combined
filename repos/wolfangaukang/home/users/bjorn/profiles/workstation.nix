{ config
, lib
, pkgs
, inputs
, osConfig
, ...
}:

let
  localLib = import "${inputs.self}/lib" { inherit inputs lib; };
  inherit (localLib) obtainIPV4Address;

in
{
  services.syncthing.enable = true;

  defaultajAgordoj.work.simplerisk.enable = osConfig.profile.specialisations.work.simplerisk.indicator;

  programs.ssh = {
    enable = true;
    matchBlocks = {
      surtsey = {
        user = "marx";
        hostname = obtainIPV4Address "surtsey" "brume";
        identityFile = [ "${config.home.homeDirectory}/.ssh/Keys/devices/surtsey" ];
      };
      grimsnes = {
        user = "marx";
        hostname = obtainIPV4Address "grimsnes" "brume";
        identityFile = [ "${config.home.homeDirectory}/.ssh/Keys/devices/servers" ];
      };
      arenal = {
        user = "bjorn";
        hostname = obtainIPV4Address "arenal" "activos";
        identityFile = [ "${config.home.homeDirectory}/.ssh/Keys/id" ];
      };
      irazu = {
        user = "bjorn";
        hostname = obtainIPV4Address "irazu" "activos";
        identityFile = [ "${config.home.homeDirectory}/.ssh/Keys/id" ];
      };
    };
  };

  home.packages = with pkgs; [
    telegram-desktop
    tutanota-desktop
  ];

  sops = {
    defaultSopsFile = ../secrets.yaml;
    #gnupg.home = "${config.home.homeDirectory}/.gnupg";
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    secrets = {
      "github_pat/nixpkgs-review" = {
        mode = "0700";
        path = "${config.home.homeDirectory}/.nixpkgs-review";
      };
      "pypi_tokens/python_trovo" = {
        mode = "0700";
        path = "${config.home.homeDirectory}/.pypi_python_trovo";
      };
    };
  };
}
