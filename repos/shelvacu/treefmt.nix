{ pkgs, ... }:
let
  shellFiles = [
    "*.sh"
    "*.bash"
    "dcd"
    "dliam"
    "dmmm"
    "dnod"
    "sops"
    "tliam"
  ];
in
{
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;
  programs.nixfmt.strict = true;
  # programs.shellcheck = {
  #   enable = true;
  #   includes = shellFiles;
  # };
  # settings.formatter.shellcheck.options = [
  #   "--external-sources"
  #   "--norc"
  #   "--source-path=${pkgs.shellvaculib}/bin"
  #   "--enable=all"
  #   "--exclude=SC2250,SC2016"
  # ];
  programs.shfmt.enable = true;
  programs.shfmt.includes = shellFiles;
  programs.deno.enable = true;
  programs.stylua.enable = true;
  programs.black.enable = true;
  settings.excludes = [
    "*.pdf"
    "*.patch"
    "*.units"

    ".gitignore"
    "flake.lock"

    "mmm/firmware/all_firmware.tar.gz"
    "mmm/firmware/kernelcache.release.mac13g"

    "secrets/*"
  ];
}
