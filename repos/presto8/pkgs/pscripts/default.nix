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
    rev = "1482abc3bc9cb7471d99a3b85e8598174e885461";
    hash = "sha256-R6C0Oz0tJA/kZQtjcy77WQrUeJaltR1r4eI6Ihr+/tY=";
  };

  installPhase = ''
    runHook preInstall

    for exe in lastf pdrives pfs phash pmove pnix psg; do
      install -D -m 755 "$exe"/"$exe" $out/bin/"$exe"
    done

    runHook postInstall
  '';
})
