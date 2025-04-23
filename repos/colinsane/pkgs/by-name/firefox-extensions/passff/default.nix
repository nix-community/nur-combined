{
  fetchFromGitea,
  gitUpdater,
  stdenv,
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

  nativeBuildInputs = [ zip ];

  makeFlags = [
    "VERSION=${version}"
  ];

  installPhase = ''
    runHook preInstall
    install bin/$version/passff.xpi $out
    runHook postInstall
  '';

  passthru.updateScript = gitUpdater { };
  passthru.extid = "passff@invicem.pro";
}
