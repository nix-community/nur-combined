{
  fetchFromGitHub,
  stdenv,
  unstableGitUpdater,
}:
stdenv.mkDerivation {
  pname = "uAssets";
  version = "0-unstable-2026-02-15";

  src = fetchFromGitHub {
    owner = "ublockorigin";
    repo = "uAssets";
    rev = "b4aba690c91259722b7ddd688cdb91b7d77104c9";
    hash = "sha256-Hk6bvmfl9Is6SpHkurrAPgH/X1nTfCPDzOXkK2fGXo8=";
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
