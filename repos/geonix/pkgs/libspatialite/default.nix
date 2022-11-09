{ lib
, stdenv
, fetchurl
, pkg-config
, validatePkgConfig
# , freexl  TODO: re-enable freexl in 22.11 (freexl is not available in 22.05)
, geos
, librttopo
, libxml2
, minizip
, proj
, sqlite
, libiconv
}:

stdenv.mkDerivation rec {
  pname = "libspatialite";
  version = "5.0.1";

  outputs = [ "out" "dev" ];

  src = fetchurl {
    url = "https://www.gaia-gis.it/gaia-sins/libspatialite-${version}.tar.gz";
    hash = "sha256-7svJQxHHgBLQWevA+uhupe9u7LEzA+boKzdTwbNAnpg=";
  };

  nativeBuildInputs = [
    pkg-config
    validatePkgConfig
    geos # for geos-config
  ];

  buildInputs = [
    # freexl  TODO: re-enable freexl in 22.11
    geos
    librttopo
    libxml2
    minizip
    proj
    sqlite
  ] ++ lib.optionals stdenv.isDarwin [
    libiconv
  ];

  configureFlags = [ "--disable-freexl" ];  # TODO: drop this in 22.11

  enableParallelBuilding = true;

  postInstall = lib.optionalString stdenv.isDarwin ''
    ln -s $out/lib/mod_spatialite.{so,dylib}
  '';

  # Failed tests (linux & darwin):
  # - check_virtualtable6
  # - check_drop_rename
  doCheck = false;

  preCheck = ''
    export LD_LIBRARY_PATH=$(pwd)/src/.libs
    export DYLD_LIBRARY_PATH=$(pwd)/src/.libs
  '';

  meta = with lib; {
    description = "Extensible spatial index library in C++";
    homepage = "https://www.gaia-gis.it/fossil/libspatialite";
    # They allow any of these
    license = with licenses; [ gpl2Plus lgpl21Plus mpl11 ];
    platforms = platforms.unix;
    maintainers = with maintainers; [ dotlambda ];
  };
}
