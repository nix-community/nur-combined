{
  fetchFromGitHub,
  stdenv,
  unstableGitUpdater,
}:
stdenv.mkDerivation {
  pname = "uProd";
  version = "0-unstable-2026-01-16";

  src = fetchFromGitHub {
    owner = "ublockorigin";
    repo = "uAssets";
    rev = "41331ec851dcdc6f09a800c95b4edaf342f1cfbe";
    hash = "sha256-e2OjI1rKvHZhv68g9VW1xXUfkeWE4y4eQetQnJcpQnI=";
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
