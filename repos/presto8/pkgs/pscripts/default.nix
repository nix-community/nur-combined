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
    rev = "fc32b9eda68e2f3fe265d0e3301d3305d5bcb015";
    hash = "sha256-YQ2pYhJgXpAWtmWSkKLUlFsLmGd8YJ5Ue80NCbcc6m0=";
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
