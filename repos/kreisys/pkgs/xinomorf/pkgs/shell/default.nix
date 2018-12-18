{ mkShell, wrapper, bashInteractive, cli, aliases
, name }:

mkShell {
  buildInputs = [ aliases bashInteractive cli wrapper ];
  XMF_DEPLOY = name;
  shellHook = ''
    if ! env | grep '^DIRENV' &>/dev/null; then
      # We aren't allowed to print anything when
      # using direnv nix integration...
      echo "NO DIRENV"
    fi
  '';
}
