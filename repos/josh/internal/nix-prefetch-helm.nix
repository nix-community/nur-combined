{
  lib,
  writeShellApplication,
  coreutils,
  kubernetes-helm,
  nix,
}:
writeShellApplication {
  name = "nix-prefetch-helm";

  runtimeInputs = [
    coreutils
    kubernetes-helm
    nix
  ];

  text = ''
    TMPDIR=$(mktemp -d)
    export HELM_CACHE_HOME=$TMPDIR/cache

    mkdir -p "$TMPDIR/out"
    helm pull "$@" --destination "$TMPDIR/out" --untar >&2
    nix-hash --type sha256 --sri "$TMPDIR"/out/*
  '';

  meta = {
    description = "Script used to obtain source hashes for fetchhelm";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
