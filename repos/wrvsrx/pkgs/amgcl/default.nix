{
  stdenv,
  cmake,
  source,
}:
stdenv.mkDerivation {
  inherit (source) pname src;
  version = "1.4.5-unstable-" + source.date;
  nativeBuildInputs = [ cmake ];
}
