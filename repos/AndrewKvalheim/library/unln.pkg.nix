{ writeShellApplication

  # Dependencies
, uutils-coreutils-noprefix
}:

writeShellApplication {
  name = "unln";

  runtimeInputs = [ uutils-coreutils-noprefix ];

  text = ''
    canonical="$(readlink --canonicalize-existing "$1")"
    cp --remove-destination --verbose "$canonical" "$1"
  '';
}
