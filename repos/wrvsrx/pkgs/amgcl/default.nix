{
  stdenv,
  cmake,
  source,
}:
stdenv.mkDerivation {
  inherit (source) pname src version;
  nativeBuildInputs = [ cmake ];
}
