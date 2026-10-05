# Wrap a package's pkgs/<name>/update.py in a command with pinned runtime
# dependencies and expose it as the standard passthru.updateScript.
#
# The script path is resolved from $PWD at run time on purpose: the updater
# edits the working tree, so it must run from the repository root (e.g.
# nix run .#<name>.updateScript), not from a read-only store copy.
{
  writeShellApplication,
  python3,
  nix,
  git,
  cacert,
}:
{
  name,
  extraRuntimeInputs ? [ ],
}:
writeShellApplication {
  name = "update-${name}";
  runtimeInputs =
    [
      python3
      nix
      git
      cacert
    ]
    ++ extraRuntimeInputs;
  text = ''
    export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
    exec python3 "$PWD/pkgs/${name}/update.py" "$@"
  '';
}
