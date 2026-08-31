{
  lib,
  stdenv,
  fetchFromGitHub,
  qt6,
  xcbuild,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qtester104";
  version = "2.7.2";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "riclolsen";
    repo = "qtester104";
    tag = "V${finalAttrs.version}";
    hash = "sha256-Gk4Cu1WA5L6KrplNlfNTX6p+dYTegAHpJmNsLpe6tC4=";
  };

  nativeBuildInputs = [
    qt6.qmake
    qt6.wrapQtAppsHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    xcbuild # for plutil
  ];

  postInstall =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      install -Dm755 QTester104 -t $out/bin
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/Applications
      mv QTester104.app $out/Applications
    '';

  meta = {
    description = "Protocol tester for IEC60870-5-104 protocol";
    homepage = "https://github.com/riclolsen/qtester104";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
