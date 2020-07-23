{ stdenv
, mkDerivation
, lib
, gdal
, cmake
, ninja
, proj
, clipper
, zlib
, qttools
, qtlocation
, qtsensors
, qttranslations
, doxygen
, cups
, wrapQtAppsHook
, qtimageformats
, sources
, substituteAll
}:
let
  pname = "OpenOrienteering-Mapper";
  date = lib.substring 0 10 sources.mapper.date;
  version = "unstable-" + date;
in
mkDerivation {
  inherit pname version;
  src = sources.mapper;

  patches = [
    (substituteAll {
      # See https://github.com/NixOS/nixpkgs/issues/86054
      src = ./fix-qttranslations-path.patch;
      inherit qttranslations;
    })
    # See https://github.com/OpenOrienteering/mapper/issues/1042
    ./add-nakarte-link.patch
  ];

  buildInputs = [
    gdal
    qtlocation
    qtimageformats
    qtsensors
    clipper
    zlib
    proj
    cups
  ];

  nativeBuildInputs = [ cmake doxygen ninja qttools ];

  cmakeFlags = [
    # Building the manual and bundling licenses fails
    # See https://github.com/NixOS/nixpkgs/issues/85306
    "-DLICENSING_PROVIDER:BOOL=OFF"
    "-DMapper_MANUAL_QTHELP:BOOL=OFF"
    "-DMapper_VERSION_DISPLAY=${version}"
  ] ++ lib.optionals stdenv.isDarwin [
    # Usually enabled on Darwin
    "-DCMAKE_FIND_FRAMEWORK=never"
    # FindGDAL is broken and always finds /Library/Framework unless this is
    # specified
    "-DGDAL_INCLUDE_DIR=${gdal}/include"
    "-DGDAL_CONFIG=${gdal}/bin/gdal-config"
    "-DGDAL_LIBRARY=${gdal}/lib/libgdal.dylib"
    # Don't bundle libraries
    "-DMapper_PACKAGE_PROJ=0"
    "-DMapper_PACKAGE_QT=0"
    "-DMapper_PACKAGE_ASSISTANT=0"
    "-DMapper_PACKAGE_GDAL=0"
  ];

  postInstall = lib.optionalString stdenv.isDarwin ''
    mkdir -p $out/Applications
    mv $out/Mapper.app $out/Applications
    # Fixes "This application failed to start because it could not find or load the Qt
    # platform plugin "cocoa"."
    wrapQtApp $out/Applications/Mapper.app/Contents/MacOS/Mapper
    mkdir -p $out/bin
    ln -s $out/Applications/Mapper.app/Contents/MacOS/Mapper $out/bin/mapper
  '';

  meta = with lib; {
    inherit (sources.mapper) description homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
