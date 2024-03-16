{
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation(finalAttrs: {
  pname = "pscripts";
  version = "2024-03-02";

  src = fetchFromGitHub {
    owner = "presto8";
    repo = "pscripts";
    rev = "b6787debb0e3c50ff7166fc8ce674607e8c114f8";
    hash = "sha256-7n/PQNIPt3ZZuyUQRgDjM0RFoUFG7JPv+Z5zMTSDL6k=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    for exe in lastf pdrives pfs phash pmove pnix psg; do
      install -D -m 755 "$exe"/"$exe" $out/bin/"$exe"
    done

    runHook postInstall
  '';
})
