{
  stdenv,
  cmake,
  source,
  zlib,
}:
stdenv.mkDerivation {
  inherit (source) pname src;
  version = "0-unstable-" + source.date;
  patches = [ ./pc.patch ];
  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ zlib ];
}
