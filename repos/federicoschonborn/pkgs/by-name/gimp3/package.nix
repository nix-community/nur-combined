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
  validatePkgConfig,
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
  testers,
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
    validatePkgConfig
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
    substituteInPlace devel-docs/reference/gimp{,-ui}/meson.build --replace-fail "'--fatal-warnings'" "# '--fatal-warnings'"
    patchShebangs --build app/tests/create_test_env.sh tools/gimp-mkenums
  '';

  preConfigure = ''
    # The check runs before glib-networking is registered
    export GIO_EXTRA_MODULES="${glib-networking}/lib/gio/modules:$GIO_EXTRA_MODULES"
  '';

  postFixup = ''
    patchShebangs --host $(grep -Rl /usr/bin/env $out/lib)
    substituteInPlace $(grep -Rl /usr/bin/env $out/lib) --replace-fail "/usr/bin/env gimp-script-fu-interpreter-3.0" "$out/bin/gimp-script-fu-interpreter-3.0"
  '';

  doCheck = true;

  mesonCheckFlags = [
    # Makes network requests
    "--no-suite"
    "gimp:desktop"
  ];

  strictDeps = true;

  passthru.tests.pkg-config = testers.hasPkgConfigModules {
    package = finalAttrs.finalPackage;
    versionCheck = true;
  };

  meta = {
    mainProgram = "gimp";
    description = "GNU Image Manipulation Program";
    homepage = "https://www.gimp.org/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    pkgConfigModules = [
      "gimp-3.0"
      "gimpthumb-3.0"
      "gimpui-3.0"
    ];
  };
})
