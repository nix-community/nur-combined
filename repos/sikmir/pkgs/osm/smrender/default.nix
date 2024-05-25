{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  cairo,
  librsvg,
  Foundation,
  memstreamHook,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "smrender";
  version = "4.3.0";

  src = fetchFromGitHub {
    owner = "rahra";
    repo = "smrender";
    rev = "v${finalAttrs.version}";
    hash = "sha256-b9xuOPLxA9zZzIwWl+FTSW5XHgJ2sFoC578ZH6iwjaM=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs =
    [
      cairo
      librsvg
    ]
    ++ lib.optionals stdenv.isDarwin [
      Foundation
      memstreamHook
    ];

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
    version = "V${finalAttrs.version}";
  };

  meta = {
    description = "A powerful, flexible, and modular rule-based rendering engine for OSM data";
    inherit (finalAttrs.src.meta) homepage;
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
