{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  autoreconfHook,
  pkg-config,
  cairo,
  librsvg,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "smrender";
  version = "4.4.2";

  src = fetchFromGitHub {
    owner = "rahra";
    repo = "smrender";
    tag = "v${finalAttrs.version}";
    hash = "sha256-u+zZUqWWFn1AjuiYGhh8ZfRSI/4GS9ThVH1KHtbROE8=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/rahra/smrender/pull/16/commits/367fe9a14ce3f683a61de79b24f5025ab7f19253.patch";
      hash = "sha256-Bn02ayB4qo3BXbF8hLa0NvGXcMAs1mZWgt6JsdVFAKE=";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    cairo
    librsvg
  ];

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
    version = "V${finalAttrs.version}";
  };

  meta = {
    description = "A powerful, flexible, and modular rule-based rendering engine for OSM data";
    homepage = "https://github.com/rahra/smrender";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
