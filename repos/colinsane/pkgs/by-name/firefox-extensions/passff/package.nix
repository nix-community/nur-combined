{
  fetchFromGitea,
  gitUpdater,
  stdenvNoCC,
  wrapFirefoxAddonsHook,
  zip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "passff";
  version = "1.24";
  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "PassFF";
    repo = "passff";
    rev = finalAttrs.version;
    hash = "sha256-beO2SldIEnzcCqRuiyafzVD1YQ4tHpIL11tsGIU6Vfw=";
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
