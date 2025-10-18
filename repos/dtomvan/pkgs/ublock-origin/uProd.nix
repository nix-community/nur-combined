{
  fetchFromGitHub,
  stdenv,
  unstableGitUpdater,
}:
stdenv.mkDerivation {
  pname = "uProd";
  version = "0-unstable-2025-10-18";

  src = fetchFromGitHub {
    owner = "ublockorigin";
    repo = "uAssets";
    rev = "30c16e43d941e57ad4b1117e56c972bed9580fa8";
    hash = "sha256-KsMeSFnf623JUVdIr6xqWWfUnFOF0sCmzpilwBD2PAs=";
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
