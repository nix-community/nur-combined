# Runs nix-update's --flake evaluation against a throwaway flake, the same
# path every package update takes, so a nixpkgs bump that pairs nix-update
# with an incompatible Nix fails here instead of in the update workflow.
# See Mic92/nix-update#693.
{
  git,
  nix-update,
  runCommand,
}:
runCommand "check-nix-update"
  {
    nativeBuildInputs = [
      git
      nix-update
    ];
  }
  ''
    export HOME=$TMPDIR
    export NIX_REMOTE=local?root=$TMPDIR/store
    export NIX_CONFIG="experimental-features = nix-command flakes"

    mkdir flake
    cd flake
    cat >flake.nix <<'EOF'
    {
      outputs = _: {
        packages.''${builtins.currentSystem}.probe = {
          type = "derivation";
          name = "probe-1.0";
          version = "1.0";
          src = { };
        };
      };
    }
    EOF
    git init --quiet
    git add flake.nix

    nix-update --flake --version=skip probe
    touch $out
  ''
