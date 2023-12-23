{
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation(finalAttrs: {
  pname = "pscripts";
  version = "2023-11-29";

  src = fetchFromGitHub {
    owner = "presto8";
    repo = "pscripts";
    rev = "6879ff898cd649df61744c764eeee471d50131ab";
    hash = "sha256-sfnCrZ0f3dJ1NECFD+PNsABPs4W9VnSIpIMfJJP0Shc=";
  };

  installPhase = ''
    runHook preInstall

    for exe in lastf pdrives phash pmove pnix psg; do
      install -D -m 755 "$exe"/"$exe" $out/bin/"$exe"
    done

    runHook postInstall
  '';
})
