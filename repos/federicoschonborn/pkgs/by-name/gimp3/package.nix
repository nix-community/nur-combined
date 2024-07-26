{
  lib,
  stdenv,
  fetchzip,
  appstream,
  desktop-file-utils,
  gi-docgen,
  gjs,
  gobject-introspection,
  libxml2,
  libxslt,
  luajit,
  meson,
  ninja,
  perl,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook,
  aalib,
  alsa-lib,
  appstream-glib,
  at-spi2-atk,
  babl,
  bzip2,
  cairo,
  cfitsio,
  fontconfig,
  freetype,
  gdk-pixbuf,
  gegl,
  gexiv2,
  ghostscript,
  glib-networking,
  glib,
  gtk3,
  harfbuzz,
  isocodes,
  json-glib,
  lcms,
  libarchive,
  libbacktrace,
  libgudev,
  libheif,
  libiff,
  libilbm,
  libjpeg,
  libjxl,
  libmng,
  libmypaint,
  libpng,
  librsvg,
  libtiff,
  libunwind,
  libwebp,
  libwmf,
  mypaint-brushes1,
  openexr,
  openjpeg,
  pango,
  poppler_data,
  poppler,
  qoi,
  shared-mime-info,
  xorg,
  xz,
  zlib,
}:

let
  luajitEnv = luajit.withPackages (ps: [ ps.lgi ]);
  pythonEnv = python3.withPackages (ps: [ ps.pygobject3 ]);
in

stdenv.mkDerivation (finalAttrs: {
  pname = "gimp";
  version = "2.99.18";

  src = fetchzip {
    url = "https://download.gimp.org/gimp/v${lib.versions.majorMinor finalAttrs.version}/gimp-${finalAttrs.version}.tar.xz";
    hash = "sha256-SAuw8pPZKlyTs0jFe+Lq8RQtAReGthhpo8kG2d4ZN+0=";
  };

  nativeBuildInputs = [
    appstream # appstreamcli
    desktop-file-utils # desktop-file-validate
    gdk-pixbuf # gdk-pixbuf-pixdata
    gi-docgen
    gjs
    gobject-introspection
    libxml2 # xmllint
    libxslt # xsltproc
    luajitEnv
    meson
    ninja
    perl
    pkg-config
    pythonEnv
    vala
    wrapGAppsHook
  ];

  buildInputs = [
    aalib
    alsa-lib
    appstream-glib
    at-spi2-atk
    babl
    bzip2
    cairo
    cfitsio
    fontconfig
    freetype
    gdk-pixbuf
    gegl
    gexiv2
    ghostscript
    gjs
    glib
    glib-networking
    gtk3
    harfbuzz
    isocodes
    json-glib
    lcms
    libarchive
    libbacktrace
    libgudev
    libheif
    libiff
    libilbm
    libjpeg
    libjxl
    libmng
    libmypaint
    libpng
    librsvg
    libtiff
    libunwind
    libwebp
    libwmf
    luajitEnv
    mypaint-brushes1
    openexr
    openjpeg
    pango
    poppler
    poppler_data
    pythonEnv
    qoi
    shared-mime-info
    xorg.libX11
    xorg.libXcursor
    xorg.libXext
    xorg.libXfixes
    xorg.libXmu
    xorg.libXpm
    xz
    zlib
  ];

  mesonFlags = [ (lib.mesonEnable "headless-tests" false) ];

  postPatch = ''
    substituteInPlace meson.build --replace-fail "if not glib_networking_works" "if glib_networking_works"
    substituteInPlace devel-docs/reference/gimp{,-ui}/meson.build --replace-fail "'--fatal-warnings'" "# '--fatal-warnings'"
    patchShebangs --build app/tests/create_test_env.sh tools/gimp-mkenums
  '';

  postFixup = ''
    patchShebangs --host $(grep -Rl /usr/bin/env $out/lib)
    substituteInPlace $(grep -Rl /usr/bin/env $out/lib) --replace-fail "/usr/bin/env gimp-script-fu-interpreter-3.0" "$out/bin/gimp-script-fu-interpreter-3.0"
  '';

  strictDeps = true;

  meta = {
    mainProgram = "gimp";
    description = "GNU Image Manipulation Program";
    homepage = "https://www.gimp.org/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
