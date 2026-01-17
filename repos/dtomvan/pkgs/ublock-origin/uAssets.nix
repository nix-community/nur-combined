{
  fetchFromGitHub,
  stdenv,
  unstableGitUpdater,
}:
stdenv.mkDerivation {
  pname = "uAssets";
  version = "0-unstable-2026-01-16";

  src = fetchFromGitHub {
    owner = "ublockorigin";
    repo = "uAssets";
    rev = "4badd1d90622e71fc52e35bfea0237a7fc0b240f";
    hash = "sha256-0hSNHKyM6vARHASxRjZIWY/JvqH1uN4LX+Hk5F26+yc=";
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
