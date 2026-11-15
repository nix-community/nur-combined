{
  lib,
  writeShellApplication,
  python3,
  nix,
  nix-prefetch-scripts,
  git,
  cacert,
  pname,
}:

writeShellApplication {
  name = "update-${pname}";
  runtimeInputs = [
    python3
    nix
    nix-prefetch-scripts
    git
  ];
  text = ''
    export UPDATE_NIX_ATTR_PATH=${lib.escapeShellArg pname}
    export SSL_CERT_FILE=${lib.escapeShellArg "${cacert}/etc/ssl/certs/ca-bundle.crt"}
    export NIX_SSL_CERT_FILE="$SSL_CERT_FILE"
    cd "$(git rev-parse --show-toplevel)"
    exec python3 ${./update.py} ${lib.escapeShellArg pname} "$@"
  '';
}
