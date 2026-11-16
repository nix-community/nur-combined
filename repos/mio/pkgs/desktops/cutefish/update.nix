{
  lib,
  writeShellApplication,
  python3,
  nix,
  git,
  cacert,
  pname,
}:

writeShellApplication {
  name = "update-${pname}";
  # nix-prefetch-url is part of nix.
  runtimeInputs = [
    python3
    nix
    git
  ];
  text = ''
    export UPDATE_NIX_ATTR_PATH=${lib.escapeShellArg pname}
    export SSL_CERT_FILE=${lib.escapeShellArg "${cacert}/etc/ssl/certs/ca-bundle.crt"}
    export NIX_SSL_CERT_FILE="$SSL_CERT_FILE"
    cd "$(git rev-parse --show-toplevel)"
    # Without arguments update.py reads UPDATE_NIX_ATTR_PATH; --all and package
    # names are passed through as given.
    exec python3 ${./update.py} "$@"
  '';
}
