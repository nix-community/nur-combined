# generate a base derivation to help creating development packages for c++ meson+ninja+pkg-config projects.
# the base derivation is not buildable as it lacks src, it is meant to be overridden.
{ stdenv, lib
, meson, ninja, pkgconfig
, debug ? false
, werror ? false
, doCoverage ? false
, coverageGcnoGlob ? "*/*.gcno"
}:

stdenv.mkDerivation {
  nativeBuildInputs = [
    meson
    ninja
    pkgconfig
  ];

  CXXFLAGS = if debug then "-O0" else "";

  mesonBuildType = if debug then "debug" else "release";
  dontStrip = debug;
  hardeningDisable = if debug then [ "fortify" ] else [];
  ninjaFlags = [ "-v" ];

  mesonFlags = [ "--warnlevel=3" ]
    ++ lib.optional werror [ "--werror" ]
    ++ lib.optional doCoverage [ "-Db_coverage=true" ];

  postInstall = lib.optionalString doCoverage ''
    mkdir -p $out/gcno
    cp ${coverageGcnoGlob} $out/gcno/
  '';
}
