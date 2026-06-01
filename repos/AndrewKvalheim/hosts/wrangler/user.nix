{ lib, pkgs, ... }:

let
  inherit (lib) getExe;

  system = import <nixpkgs/nixos> { };

  # Packages
  pretty-whois = with pkgs; writeShellScriptBin "pretty-whois" ''
    set -Eeuo pipefail

    ${getExe whois} "$@" \
      | ${getExe ack} --color-match 'bold blue' --passthru '[-\w.!$%+=]+@[-\w.]+'
  '';
in
{
  imports = [
    ../../user.nix
    ./user.local.nix
  ];

  # Nix
  home.stateVersion = "22.05"; # Permanent

  # System configuration
  system = system.config;

  # Host parameters
  host = {
    dir = ./.;
    firefox.profile = "f2y424q1.default";
  };

  # Unfree packages
  nixpkgs.config.allowUnfreePackages = [
    "zoom"
  ];

  # Display
  xdg.dataFile."icc/ThinkPad-T14.icc".source = ./assets/ThinkPad-T14.icc;

  # Applications
  home.packages = with pkgs; [
    awscli2
    chromium
    powershell
    pretty-whois
    teams-for-linux
    thunderbird
    tor-browser
    transmission_4-gtk
    zoom-us
  ];
  programs.zsh.initContent = ''
    function asn() {
      ${getExe pkgs.mmdbinspect} --db '/var/lib/GeoIP/GeoLite2-ASN.mmdb' "$1" \
      | ${getExe pkgs.jq} --raw-output '.[0].Records[] | "\(.Network) AS\(.Record.autonomous_system_number) “\(.Record.autonomous_system_organization)”"'
    }
  '';
  programs.zsh.shellAliases.w = "pretty-whois";

  # File type associations
  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/mailto" = "thunderbird.desktop";
  };
}
