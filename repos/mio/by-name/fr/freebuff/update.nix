{
  writeShellApplication,
  python3,
  bun,
  nix,
  cacert,
  git,
  attrPath ? "freebuff",
}:

writeShellApplication {
  name = "update-${attrPath}";
  runtimeInputs = [
    python3
    bun
    nix
    git
  ];
  text = ''
    export UPDATE_NIX_ATTR_PATH="${attrPath}"
    export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
    exec ${python3}/bin/python3 ${./update.py} "$@"
  '';
}
