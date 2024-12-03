{ pkgs, ... }:

let
  # Packages
  pretty-whois = with pkgs; writeShellScriptBin "pretty-whois" ''
    set -Eeuo pipefail

    ${whois}/bin/whois "$@" \
      | ${ack}/bin/ack --color-match 'bold blue' --passthru '[-\w.!$%+=]+@[-\w.]+'
  '';
in
{
  imports = [
    ../../common/user.nix
    ./local/user.nix
  ];

  # Nix
  home.stateVersion = "22.05"; # Permanent

  # Host parameters
  host = {
    background = "file://${./resources/background.jpg}";
    cores = 16;
    display_density = 2;
    display_width = 3840;
    firefoxProfile = "f2y424q1.default";
    local = ./local;
  };

  # Unfree packages
  allowedUnfree = [
    "zoom"
  ];

  # Display
  xdg.dataFile."icc/ThinkPad-T14.icc".source = ./resources/ThinkPad-T14.icc;

  # Applications
  home.packages = with pkgs; [
    awscli2
    chromium
    powershell
    pretty-whois
    qownnotes
    teams-for-linux
    thunderbird
    tor-browser-bundle-bin
    transmission_4-gtk
    zoom-us
  ];
  programs.zsh.initExtra = ''
    function asn() {
      ${pkgs.mmdbinspect}/bin/mmdbinspect --db '/var/lib/GeoIP/GeoLite2-ASN.mmdb' "$1" \
      | ${pkgs.jq}/bin/jq --raw-output '.[0].Records[] | "\(.Network) AS\(.Record.autonomous_system_number) “\(.Record.autonomous_system_organization)”"'
    }
  '';
  programs.zsh.shellAliases.w = "pretty-whois";

  # File type associations
  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/mailto" = "thunderbird.desktop";
  };
}
