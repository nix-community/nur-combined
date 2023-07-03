{ lib, stdenv, fetchFromGitHub, cmake, desktopToDarwinBundle, mariadb-connector-c, wrapQtAppsHook }:

stdenv.mkDerivation (finalAttrs: {
  pname = "ocelotgui ";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "ocelot-inc";
    repo = "ocelotgui";
    rev = finalAttrs.version;
    hash = "sha256-v8YMTc01bRDD5tqJIctTmtMkMD6+gh/CVKu/Vw9o7g0=";
  };

  nativeBuildInputs = [ cmake wrapQtAppsHook ]
    ++ lib.optional stdenv.isDarwin desktopToDarwinBundle;

  buildInputs = [ mariadb-connector-c ];

  cmakeFlags = [
    "-DCMAKE_SKIP_RPATH=TRUE"
    "-DMYSQL_INCLUDE_DIR=${mariadb-connector-c.dev}/include/mariadb"
    "-DQT_VERSION=5"
    "-DOCELOT_THIRD_PARTY=0"
  ];

  env.NIX_LDFLAGS = "-L${mariadb-connector-c}/lib/mariadb -lmysqlclient";

  meta = with lib; {
    description = "GUI client for MySQL or MariaDB";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.gpl2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})
