{pkgs}: let
  # Use the pinned gomod2nix CLI that supports dependency cache generation.
  gomod2nix = (pkgs.extend (import ((import ../../internal/gomod2nix.nix) + "/overlay.nix"))).gomod2nix;
  script = pkgs.writeShellApplication {
    name = "update-lockfiles";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.git
      pkgs.gnugrep
      pkgs.jq
      pkgs.nix
      pkgs.crate2nix
      pkgs.cargo
      pkgs.yq-go
      gomod2nix
    ];
    runtimeEnv.SYSTEM = pkgs.stdenv.hostPlatform.system;
    # Prepend the shared helpers rather than sourcing them at runtime: a path inside
    # the flake source is not reliably materialised when the worktree is dirty.
    text = builtins.readFile ./lib/update-utils.sh + builtins.readFile ./update-lockfiles.sh;
  };
in {
  update-lockfiles = {
    type = "app";
    program = "${script}/bin/update-lockfiles";
    meta.description = "Regenerate crate2nix Cargo.nix, gomod2nix.toml and pubspec.lock.json lockfiles for changed sources";
  };
}
