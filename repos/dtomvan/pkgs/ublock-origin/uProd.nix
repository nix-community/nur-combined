{
  fetchFromGitHub,
  stdenv,
  unstableGitUpdater,
}:
stdenv.mkDerivation {
  pname = "uProd";
  version = "0-unstable-2026-07-12";

  src = fetchFromGitHub {
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "99a1d3992bca3e006625b430bc753e576e45bc2c";
    hash = "sha256-2/tnSM9ItNvncrAZr/I3XaLKTsBzeqMci6f1uxMpz8I=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r * $out

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater {
    branch = "gh-pages";
    hardcodeZeroVersion = true;
  };
}
