{
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation(finalAttrs: {
  pname = "pscripts";
  version = "2024-04-13";

  src = fetchFromGitHub {
    owner = "presto8";
    repo = "pscripts";
    rev = "fbcfa743ec440f15a0e56fcf9abbb609abcf43c4";
    hash = "sha256-5Y6zduVf88K0DqCdfrbpQkmtiI1WT2M3fN4zH8DwD3Y=";
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
