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
    rev = "889ed5002bcf631e52f264b4c3326c93871421ab";
    hash = "sha256-T0C3r4ffOMA9nAk51xQ5cS5T0QRcXig65Bu/YyXCbbA=";
  };

  installPhase = ''
    runHook preInstall

    for exe in lastf pdrives pfs phash pmove pnix psg; do
      install -D -m 755 "$exe"/"$exe" $out/bin/"$exe"
    done

    runHook postInstall
  '';
})
