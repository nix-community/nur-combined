{
  fetchFromGitea,
  gitUpdater,
  stdenvNoCC,
  wrapFirefoxAddonsHook,
  zip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "passff";
  version = "1.23";
  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "PassFF";
    repo = "passff";
    rev = version;
    hash = "sha256-CQD9QOCV0uZDPVtrT1QQgF65ghXh1BxkUy3diuuI0ng=";
  };

  nativeBuildInputs = [
    wrapFirefoxAddonsHook
    zip
  ];

  makeFlags = [
    "VERSION=${version}"
  ];

  installPhase = ''
    runHook preInstall
    mkdir $out
    install bin/$version/passff.xpi $out/$extid.xpi
    runHook postInstall
  '';

  extid = "passff@invicem.pro";

  passthru.updateScript = gitUpdater { };
}
