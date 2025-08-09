{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  autoreconfHook,
  makeWrapper,
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
      url = "https://github.com/rahra/smrender/commit/367fe9a14ce3f683a61de79b24f5025ab7f19253.patch";
      hash = "sha256-Bn02ayB4qo3BXbF8hLa0NvGXcMAs1mZWgt6JsdVFAKE=";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    cairo
    librsvg
  ];

  postInstall = ''
    wrapProgram $out/bin/smrender \
      --prefix DYLD_LIBRARY_PATH : $out/lib/smrender \
      --prefix LD_LIBRARY_PATH : $out/lib/smrender
  '';

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
