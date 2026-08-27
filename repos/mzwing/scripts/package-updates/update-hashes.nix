# Refresh static-URL dependency hashes; update-pins handles coupled URLs and hashes.
{pkgs}: let
  script = pkgs.writeShellApplication {
    name = "update-hashes";
    runtimeInputs = [
      pkgs.findutils
      pkgs.git
      pkgs.gnugrep
      pkgs.jq
      pkgs.nix
      pkgs.nix-update
    ];
    runtimeEnv = {
      SYSTEM = pkgs.stdenv.hostPlatform.system;
      UPDATE_UTILS = ./lib/update-utils.sh;
    };
    excludeShellChecks = [
      "SC1091" # UPDATE_UTILS is injected via runtimeEnv.
    ];
    text = builtins.readFile ./update-hashes.sh;
  };
in {
  update-hashes = {
    type = "app";
    program = "${script}/bin/update-hashes";
    meta.description = "Refresh vendored dependency hashes when package hash inputs change";
  };
}
