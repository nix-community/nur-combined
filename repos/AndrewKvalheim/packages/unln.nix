{ writeShellApplication

  # Dependencies
, coreutils
}:

writeShellApplication {
  name = "unln";

  runtimeInputs = [ coreutils ];

  text = ''
    canonical="$(readlink --canonicalize-existing "$1")"
    cp --reflink=always --remove-destination --verbose "$canonical" "$1"
  '';
}
