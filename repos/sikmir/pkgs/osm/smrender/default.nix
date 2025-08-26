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
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "rahra";
    repo = "smrender";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iQSOYiRf4A6HqNmW4oWXIsGIaSHuSvE9wuIiE7JUI8w=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/rahra/smrender/commit/bdd7c69e685ef585022fac94ef75d0d7747b042d.patch";
      hash = "sha256-zj9gMgmcYHfhRt8HV7BjL9qC+XwtlwUzxrD6MO3lWDg=";
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

  configureFlags = [
    (lib.enableFeature true "threads")
    (lib.withFeature true "cairo")
    (lib.withFeature true "fontconfig")
    (lib.withFeature true "libjpeg")
    (lib.withFeature true "librsvg")
  ];

  enableParallelBuilding = true;

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
