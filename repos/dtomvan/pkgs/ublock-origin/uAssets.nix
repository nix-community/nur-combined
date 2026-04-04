{
  fetchFromGitHub,
  stdenv,
  unstableGitUpdater,
}:
stdenv.mkDerivation {
  pname = "uAssets";
  version = "0-unstable-2026-04-04";

  src = fetchFromGitHub {
    owner = "ublockorigin";
    repo = "uAssets";
    rev = "3ccb55a9a9a68b49ab7be3e8a0323a9331c9217b";
    hash = "sha256-U3Z8+N+gg7XgoDU4zYbUgYQyXzkbHrYR+iFtLwDXfVo=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r * $out

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater { };
}
