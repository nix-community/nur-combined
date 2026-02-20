{
  lib,
  stdenv,
  fetchFromGitHub,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qtester104";
  version = "2.7.2";

  src = fetchFromGitHub {
    owner = "riclolsen";
    repo = "qtester104";
    tag = "V${finalAttrs.version}";
    hash = "sha256-Gk4Cu1WA5L6KrplNlfNTX6p+dYTegAHpJmNsLpe6tC4=";
  };

  nativeBuildInputs = [
    qt6.qmake
    qt6.wrapQtAppsHook
  ];

  postInstall = ''
    install -Dm755 QTester104 -t $out/bin
  '';

  meta = {
    description = "Protocol tester for IEC60870-5-104 protocol";
    homepage = "https://github.com/riclolsen/qtester104";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
