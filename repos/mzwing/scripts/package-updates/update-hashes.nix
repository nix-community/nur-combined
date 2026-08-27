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
    runtimeEnv.SYSTEM = pkgs.stdenv.hostPlatform.system;
    # Prepend the shared helpers rather than sourcing them at runtime: a path inside
    # the flake source is not reliably materialised when the worktree is dirty.
    text = builtins.readFile ./lib/update-utils.sh + builtins.readFile ./update-hashes.sh;
  };
in {
  update-hashes = {
    type = "app";
    program = "${script}/bin/update-hashes";
    meta.description = "Refresh vendored dependency hashes when package hash inputs change";
  };
}
