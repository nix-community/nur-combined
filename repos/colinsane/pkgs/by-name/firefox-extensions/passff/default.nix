{
  fetchFromGitea,
  gitUpdater,
  stdenv,
  zip,
}:
stdenv.mkDerivation rec {
  pname = "passff";
  version = "1.21";
  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "PassFF";
    repo = "passff";
    rev = version;
    hash = "sha256-6lxtF1YI2ssYXjOscgkJj8aAtnJOJfk87SxmCVRIkRY=";
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
