{
  fetchFromGitHub,
  stdenv,
  unstableGitUpdater,
}:
stdenv.mkDerivation {
  pname = "uProd";
  version = "0-unstable-2026-02-15";

  src = fetchFromGitHub {
    owner = "ublockorigin";
    repo = "uAssets";
    rev = "80176fb166bc419e59108503dcc2ad34449388be";
    hash = "sha256-5ppX28CnCf14VGB3jUuwt2JaKGAIYyWtlHS2R4XBKTw=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r * $out

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater { branch = "gh-pages"; };
}
