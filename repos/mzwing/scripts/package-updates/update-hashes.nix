# Refresh the dependency hashes only a build reveals; nix-repin computes the rest with each package's source.
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
    runtimeEnv.SYSTEM = pkgs.stdenv.hostPlatform.system;
    text = builtins.readFile ./update-hashes.sh;
  };
in {
  update-hashes = {
    type = "app";
    program = "${script}/bin/update-hashes";
    meta.description = "Refresh vendored dependency hashes when package hash inputs change";
  };
}
