# Refresh the dependency hashes only a build reveals; nix-repin computes the rest with each package's source.
{pkgs}: let
  # Nix 2.35's `nix flake metadata` no longer copies the flake into the store, which nix-update's `--flake` relies on (Mic92/nix-update#687)
  nix-update = pkgs.nix-update.overridePythonAttrs (old: {
    patches = (old.patches or []) ++ [./nix-update-flake-prefetch.patch];
  });
  script = pkgs.writeShellApplication {
    name = "update-hashes";
    runtimeInputs = [
      pkgs.findutils
      pkgs.git
      pkgs.gnugrep
      pkgs.nix
      nix-update
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
