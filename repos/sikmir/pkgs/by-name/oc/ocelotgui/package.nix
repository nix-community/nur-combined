{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  desktopToDarwinBundle,
  mariadb-connector-c,
  qt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ocelotgui";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "ocelot-inc";
    repo = "ocelotgui";
    tag = finalAttrs.version;
    hash = "sha256-4hlYf5TIlWLpL4FczntCQWB8EGFff1KoCAYcSC4niMI=";
  };

  nativeBuildInputs = [
    cmake
    qt5.wrapQtAppsHook
  ] ++ lib.optional stdenv.isDarwin desktopToDarwinBundle;

  buildInputs = [ mariadb-connector-c ];

  cmakeFlags = [
    (lib.cmakeBool "CMAKE_SKIP_RPATH" true)
    (lib.cmakeFeature "MYSQL_INCLUDE_DIR" "${mariadb-connector-c.dev}/include/mariadb")
    (lib.cmakeFeature "QT_VERSION" "5")
    (lib.cmakeFeature "OCELOT_THIRD_PARTY" "0")
  ];

  env.NIX_LDFLAGS = "-L${mariadb-connector-c}/lib/mariadb -lmysqlclient";

  meta = {
    description = "GUI client for MySQL or MariaDB";
    homepage = "https://github.com/ocelot-inc/ocelotgui";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "ocelotgui";
  };
})
