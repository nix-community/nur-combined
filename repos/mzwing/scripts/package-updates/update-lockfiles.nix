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
    runtimeEnv = {
      SYSTEM = pkgs.stdenv.hostPlatform.system;
      UPDATE_UTILS = ./lib/update-utils.sh;
    };
    excludeShellChecks = [
      "SC1091" # UPDATE_UTILS is injected via runtimeEnv.
    ];
    text = builtins.readFile ./update-lockfiles.sh;
  };
in {
  update-lockfiles = {
    type = "app";
    program = "${script}/bin/update-lockfiles";
    meta.description = "Regenerate crate2nix Cargo.nix, gomod2nix.toml and pubspec.lock.json lockfiles for changed sources";
  };
}
