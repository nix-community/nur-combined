{
  fetchFromGitea,
  gitUpdater,
  stdenv,
  wrapFirefoxAddonsHook,
  zip,
}:
stdenv.mkDerivation rec {
  pname = "passff";
  version = "1.22.1";
  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "PassFF";
    repo = "passff";
    rev = version;
    hash = "sha256-XtKrVrXpvsz/7XaGiYW0dxRZr7wLGNK+C6c9BHqY7Gw=";
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
