{ stdenv
, lib
, gdal
, cmake
, ninja
, proj
, clipper
, zlib
, qtbase
, qttools
, qtlocation
, qtsensors
, qttranslations
, doxygen
, cups
, wrapQtAppsHook
, qtimageformats
, sources
}:

stdenv.mkDerivation rec {
  pname = "OpenOrienteering-Mapper";
  version = lib.substring 0 7 src.rev;
  src = sources.mapper;

  patches = [
    # See https://github.com/NixOS/nixpkgs/issues/86054
    ./fix-qttranslations-path.diff
  ];

  buildInputs = [
    gdal
    qtbase
    qttools
    qtlocation
    qtimageformats
    qtsensors
    clipper
    zlib
    proj
    doxygen
    cups
  ];

  nativeBuildInputs = [ cmake wrapQtAppsHook ninja ];

  postPatch = ''
    substituteInPlace src/util/translation_util.cpp \
      --subst-var-by qttranslations ${qttranslations}
  '';

  cmakeFlags = [
    # Building the manual and bundling licenses fails
    "-DLICENSING_PROVIDER:BOOL=OFF"
    "-DMapper_MANUAL_QTHELP:BOOL=OFF"
  ] ++ (
    lib.optionals stdenv.isDarwin [
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
    ]
  );

  postInstall = lib.optionalString stdenv.isDarwin ''
    mkdir -p $out/Applications
    mv $out/Mapper.app $out/Applications
    # Fixes "This application failed to start because it could not find or load the Qt
    # platform plugin "cocoa"."
    wrapQtApp $out/Applications/Mapper.app/Contents/MacOS/Mapper
  '';

  meta = with lib; {
    inherit (src) description homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = with platforms; linux ++ darwin;
  };
}
