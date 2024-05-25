{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  desktopToDarwinBundle,
  mariadb-connector-c,
  wrapQtAppsHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ocelotgui";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "ocelot-inc";
    repo = "ocelotgui";
    rev = finalAttrs.version;
    hash = "sha256-CmLF8HrwdmWatFljSGLpy5YImlBGhjooB1K+axIDWhU=";
  };

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
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
    inherit (finalAttrs.src.meta) homepage;
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "ocelotgui";
  };
})
