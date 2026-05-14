{ writeShellApplication

  # Dependencies
, uutils-coreutils
}:

let
  uutils-coreutils' = uutils-coreutils.override { prefix = null; };
in
writeShellApplication {
  name = "unln";

  runtimeInputs = [ uutils-coreutils' ];

  text = ''
    canonical="$(readlink --canonicalize-existing "$1")"
    cp --remove-destination --verbose "$canonical" "$1"
  '';
}
