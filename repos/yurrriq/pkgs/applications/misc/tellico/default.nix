{ stdenv, fetchurl
, cmake, extra-cmake-modules, gettext, kdoctools, pkgconfig
, karchive, kconfig, kcodecs, kconfigwidgets, kcoreaddons, kcrash, kguiaddons
, khtml, kiconthemes, kitemmodels, ki18n, kjobwidgets, kio, solid, kwallet
, kwidgetsaddons, kwindowsystem, kxmlgui
, libxml2, libxslt, qtbase, python2
, exempi, libcdio, libv4l, qimageblitz, taglib
, libksane, kfilemetadata, knewstuff
, enableCdtext ? false
, enableAddressBook ? false
, enableFileMetadata ? true
, enableGradients ? false
, enableNewStuff ? false
, enableMultimediaFiles ? true
, enableScannedImages ? false
, enableWebcam ? false
, enableXMPMetadata ? true
}:

stdenv.mkDerivation rec {
  name = "tellico-${version}";
  inherit (meta) version;

  src = fetchurl {
    url = "${meta.homepage}/files/${name}.tar.xz";
    sha256 = "08gj0bhxmzhpmsma7p7941jddxcfwj0gqrx53gxh38lblalr0hzr";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = let inherit (stdenv.lib) optional; in
    [ cmake
      extra-cmake-modules
      gettext
      kdoctools
      pkgconfig ];

  buildInputs =
    [ karchive
      kconfig
      kcodecs
      kconfigwidgets
      kcoreaddons
      kcrash
      kguiaddons
      khtml
      kiconthemes
      kitemmodels
      ki18n
      kjobwidgets
      kio
      solid
      kwallet
      kwidgetsaddons
      kwindowsystem
      kxmlgui
      qtbase
      python2 ] ++ (let inherit (stdenv.lib) optional; in
    (optional enableFileMetadata kfilemetadata) ++
    (optional enableNewStuff knewstuff) ++
    # TODO: (optional enableCDDB libkcddb) ++
    (optional enableScannedImages libksane) ++
    # TODO: (optional enableAddressBook libkdepim) ++
    (optional enableCdtext libcdio) ++
    (optional enableGradients qimageblitz) ++
    (optional enableMultimediaFiles taglib) ++
    (optional enableWebcam libv4l) ++
    (optional enableXMPMetadata exempi));
    # TODO: (optional enableCSV libcsv) ++
    # TODO: (optional enableBibTeX bibtex) ++
    # TODO: (optional enableYaz yaz);

  configurePhase = ''
    mkdir build
    cd build
    cmake .. -DBUILD_TESTS=TRUE -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=$out
  '';

  checkTarget = "test";

  doCheck = false; # FIXME

  meta = with stdenv.lib; {
    version = "3.1.2";
    description = "A collection manager for books, movies, music, and anything else";
    longDescription = ''
      Tellico makes it easy to track your books, videos, music, even your wine
      and anything else. A simple and intuitive interface shows cover images,
      groupings, and any detail you want. Grab information from many popular
      Internet sites, including IMDB.com, Amazon.com, and most libraries.
    '';
    homepage = http://tellico-project.org/;
    license = licenses.gpl20;
    maintainers = with maintainers; [ yurrriq ];
    platforms = platforms.linux;
  };
}
