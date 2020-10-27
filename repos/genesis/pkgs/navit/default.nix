{ stdenv, fetchFromGitHub, pkgconfig, fontconfig, freetype, imlib2
, SDL_image, libXmu, dbus, dbus-glib, glib
, librsvg #inkscape
, libxslt, cairo, gdk_pixbuf, pango
, atk, patchelf, fetchurl, bzip2, python, gettext
, libpng, zlib, nsis, gpsd, shapelib
, gd, cmake, fribidi, makeWrapper, pcre
, qtSupport ? false, qtquickcontrols, qtspeech, qtsensors, qtdeclarative, qtmultimedia, qtlocation, qtbase, qtsvg  # broken: need to fix qt_qpainter
, gtkSupport ? (!stdenv.targetPlatform.isMinGW), gtk2
, sdlSupport ? (!stdenv.targetPlatform.isMinGW) , SDL
# protobufc doesnt compile on mingw (bug)
, maptoolSupport ? (!stdenv.targetPlatform.isMinGW), protobufc
, xkbdSupport ? false, xkbd
, espeakSupport ? false, espeak
, postgresqlSupport ? false, postgresql
, speechdSupport ? false, speechd ? null
, openGLSupport ? true, libGLU, freeglut, freeimage
}:

# not shipped :
# * gpx2navit_txt
# * gypsy (obsolete? https://gypsy.freedesktop.org)

assert speechdSupport -> speechd != null;

with stdenv.lib;
stdenv.mkDerivation rec {
  pname = "navit";
  version = "unstable-2020-14-10";

  src = fetchFromGitHub {
    owner = "navit-gps";
    repo = "navit";

    # #1061
    /* rev = "0a74d8a5134bf3478f09841e632e4e81ed34f15e";
    sha256 = "0n5j2g6iyb212b4g8419gnhj6py07c9a7blpsdi4bkc8v8c48z5n"; */

    rev = "55d64dd5476a9f8cca0db1c93f345ae1defccab3";
    sha256 = "0znvqbpb6wzx8fhz9ddrxa49k2pmps6rd8hfjca8p75wrw653mkv";
  };

  # avoid dynamic fetching by cmake
  sample_map = fetchurl {
    url = "http://www.navit-project.org/maps/osm_bbox_11.3,47.9,11.7,48.2.osm.bz2";
    name = "sample_map.bz2";
    sha256 = "0vg6b6rhsa2cxqj4rbhfhhfss71syhnfa6f1jg2i2d7l88dm5x7d";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace 'libspeechd.h' 'speech-dispatcher/libspeechd.h'

    #rm cmake/FindProtobuf-c.cmake
  '';

  NIX_CFLAGS_COMPILE = optional speechdSupport "-I${speechd}/include/speech-dispatcher";

  # we choose only cmdline and speech-dispatcher speech options.
  # espeak builtins is made for non-cmdline OS as winCE
  # see nano-wallet to improve that.
  cmakeFlags = [
    "-DDISABLE_QT=ON"
    "-DSAMPLE_MAP=n"
    "-DCMAKE_BUILD_TYPE=Release"
    "-Dspeech/qt5_espeak=FALSE"
    "-Dsupport/espeak=FALSE"
    # broken again :
    #"-DGIT_VERSION=${substring 0 8 src.rev}"
    "-DOpenGL_GL_PREFERENCE=GLVND"
  #  "-DCMAKE_INSTALL_PREFIX=${qtbase.dev}/lib/cmake"
  #  "-DQt5Svg_DIR=${qtsvg.dev}/lib/cmake/Qt5Svg/Qt5Svg"
  #  "-DXSLTS=windows"
  ] ++ optional gtkSupport [
      "-DGTK2_GLIBCONFIG_INCLUDE_DIR=${glib.out}/lib/glib-2.0/include"
      "-DGTK2_GDKCONFIG_INCLUDE_DIR=${gtk2.out}/lib/gtk-2.0/include" ]
    ++ optional (!maptoolSupport) [ "-DBUILD_MAPTOOL=FALSE" ]
    ++ optional stdenv.targetPlatform.isMinGW [
         "-DCMAKE_RC_COMPILER=${stdenv.cc.targetPrefix}windres" ];

  nativeBuildInputs = [ gettext makeWrapper pkgconfig cmake patchelf bzip2 libxslt ]
    ++ optional stdenv.targetPlatform.isMinGW nsis;

  buildInputs = [ libpng zlib ]
    ++ optionals stdenv.hostPlatform.isLinux [
        python gd freetype fribidi fontconfig libXmu dbus dbus-glib gpsd shapelib ]
    ++ optionals gtkSupport [ atk cairo gtk2 gdk_pixbuf pango imlib2 ]
    ++ optionals sdlSupport [ SDL SDL_image ]
    ++ optionals qtSupport [
      qtquickcontrols qtmultimedia qtspeech qtsensors
      qtbase qtlocation qtdeclarative qtsvg.dev ]
    ++ optionals openGLSupport [ freeglut libGLU freeimage ]
    ++ optional  postgresqlSupport postgresql
    ++ optional  speechdSupport speechd
    # windows
    # * build on internal stripped glib
    # * need update cpack to add zlib1.dll
    ++ optionals (!stdenv.targetPlatform.isMinGW) [ librsvg glib pcre.dev ]
    ++ optional maptoolSupport protobufc;

  # we dont want blank screen by default
  postInstall = optionalString maptoolSupport ''
      # emulate DSAMPLE_MAP
      mkdir -p $out/share/navit/maps/
      bzcat "${sample_map}" | $out/bin/maptool "$out/share/navit/maps/osm_bbox_11.3,47.9,11.7,48.2.bin"
      substituteInPlace $out/share/navit/navit.xml \
        --replace "/media/mmc2/MapsNavit/osm_europe.bin" "$out/share/navit/maps/osm_bbox_11.3,47.9,11.7,48.2.bin"
  '' + optionalString stdenv.targetPlatform.isMinGW ''
      echo $PWD
      cp ${zlib}/bin/zlib1.dll .
      cp ${zlib}/bin/zlib1.dll $out/bin/
      make package
      cp ./navit.exe $out/bin/navit-installer.exe
  '';

  meta = {
    homepage = "https://www.navit-project.org";
    description = "Car navigation system with routing engine using OSM maps";
    license = licenses.gpl2;
    maintainers = [ maintainers.genesis ];
    # windows version is still experimental.
    platforms = platforms.linux ++ platforms.windows;
  };
}
