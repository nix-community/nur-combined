{
  writeShellApplication,
  python3,
  crate2nix,
  cargo,
  rustc,
  git,
  nix,
  nix-prefetch-git,
  patch,
}:
writeShellApplication {
  name = "update-hyperhle-fork";
  runtimeInputs = [
    python3
    crate2nix
    cargo
    rustc
    git
    nix
    nix-prefetch-git
    patch
  ];
  text = ''exec python3 ${../../scripts/update-hyperhle-fork.py} "$@"'';
}
