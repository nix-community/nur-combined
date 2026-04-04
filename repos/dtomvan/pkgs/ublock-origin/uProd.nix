{
  fetchFromGitHub,
  stdenv,
  unstableGitUpdater,
}:
stdenv.mkDerivation {
  pname = "uProd";
  version = "0-unstable-2026-04-04";

  src = fetchFromGitHub {
    owner = "ublockorigin";
    repo = "uAssets";
    rev = "cfb2ded11ae09b8e833fc7f95e9b0c08dc02ba1d";
    hash = "sha256-KhlxsH8tkeWAumxzDkWGMal2kjhl4BUKwl0NAJuySTg=";
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
