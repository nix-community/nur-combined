{ ... }:
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
  programs = {
    # keep-sorted start
    black.enable = true;
    deno.enable = true;
    keep-sorted.enable = true;
    nixfmt.enable = true;
    nixfmt.strict = true;
    shfmt.enable = true;
    shfmt.includes = shellFiles;
    stylua.enable = true;
    # keep-sorted end
  };
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
