{
  fetchFromGitHub,
  stdenv,
  unstableGitUpdater,
}:
stdenv.mkDerivation {
  pname = "uAssets";
  version = "0-unstable-2026-07-12";

  src = fetchFromGitHub {
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "6004f5bd7004e1ffa15bc9e9f72f82415ccc1e11";
    hash = "sha256-HaPVmb8QY6QmENBy3xGA7wWh2KfLQAudKnBOrEIphnU=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r * $out

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater { hardcodeZeroVersion = true; };
}
