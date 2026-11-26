{
  fetchFromGitea,
  gitUpdater,
  stdenvNoCC,
  wrapFirefoxAddonsHook,
  zip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "passff";
  version = "1.25";
  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "PassFF";
    repo = "passff";
    rev = finalAttrs.version;
    hash = "sha256-1D6l5yU3HcjHLEnOzpmVVVTnvKFWH/XM8mTHh9yrFbI=";
  };

  nativeBuildInputs = [
    wrapFirefoxAddonsHook
    zip
  ];

  makeFlags = [
    "VERSION=${finalAttrs.version}"
  ];

  installPhase = ''
    runHook preInstall
    mkdir $out
    install bin/$version/passff.xpi $out/$extid.xpi
    runHook postInstall
  '';

  extid = "passff@invicem.pro";

  passthru.updateScript = gitUpdater { };
})
