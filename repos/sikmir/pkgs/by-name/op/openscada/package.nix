{
  lib,
  stdenv,
  fetchurl,

  bison,
  gettext,
  pkg-config,

  firebird,
  gd,
  libmysqlclient,
  libpq,
  libz,
  net-snmp,
  pcre,
  portaudio,
  qt6,
  sqlite,

  withFireBird ? false,
  withMySQL ? false,
  withPostgreSQL ? false,
  withSNMP ? false,
  withSoundCard ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openscada";
  version = "0.9.8";

  main_src = fetchurl {
    url = "http://oscada.org/oscadaArch/0.9/openscada-${finalAttrs.version}.tar.xz";
    hash = "sha256-UuDdURwu/hL/b3sykumLbHZXMzLh8/qmKqEsBRcaZew=";
  };

  res_src = fetchurl {
    url = "http://oscada.org/oscadaArch/0.9/openscada-res-${finalAttrs.version}.tar.xz";
    hash = "sha256-qVCmklGt9UKGFC1iiSy9+4kqfScfNIoiJeXX60bjJr0=";
  };

  srcs = [
    finalAttrs.main_src
    finalAttrs.res_src
  ];

  sourceRoot = "openscada-${finalAttrs.version}";

  postPatch = ''
    mv ../data ../doc .
  '';

  nativeBuildInputs = [
    bison
    gettext
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    gd
    libz
    pcre
    qt6.qtbase
    sqlite
  ]
  ++ lib.optional withFireBird firebird
  ++ lib.optional withMySQL libmysqlclient
  ++ lib.optional withPostgreSQL libpq
  ++ lib.optional withSNMP net-snmp
  ++ lib.optional withSoundCard portaudio;

  configureFlags = [
    (lib.enableFeature withFireBird "FireBird")
    (lib.withFeatureAs withFireBird "firebird" firebird)
    (lib.enableFeature withMySQL "MySQL")
    (lib.enableFeature withPostgreSQL "PostgreSQL")
    (lib.enableFeature withSNMP "SNMP")
    (lib.enableFeature withSoundCard "SoundCard")
  ];

  enableParallelBuilding = true;

  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration";

  meta = {
    description = "Open SCADA system";
    homepage = "http://oscada.org";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "openscada";
  };
})
