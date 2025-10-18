{
  fetchFromGitHub,
  stdenv,
  unstableGitUpdater,
}:
stdenv.mkDerivation {
  pname = "uAssets";
  version = "0-unstable-2025-10-18";

  src = fetchFromGitHub {
    owner = "ublockorigin";
    repo = "uAssets";
    rev = "9ac894c024d9b7c86adce83f116c107dcc68aade";
    hash = "sha256-qaBmoZ1kv5eZ5BhcOiq9zmnFVsrppKcL0dskDlY7/t0=";
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
