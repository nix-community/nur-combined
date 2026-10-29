{
  writeShellApplication,
  python3,
  curl,
  git,
  jq,
  nix,
  nix-prefetch-git,
  prefetch-npm-deps,
  attrPath ? "zen-browser",
}:

writeShellApplication {
  name = "update-${attrPath}";
  runtimeInputs = [
    python3
    curl
    git
    jq
    nix
    nix-prefetch-git
    prefetch-npm-deps
  ];
  text = ''
    export UPDATE_NIX_ATTR_PATH="${attrPath}"
    exec ${python3}/bin/python3 ${./update.py} "$@"
  '';
}
