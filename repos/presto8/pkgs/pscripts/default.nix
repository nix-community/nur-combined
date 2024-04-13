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
    rev = "e8504ed952c0d8a70d2c7726a2f7843ee067efb0";
    hash = "sha256-s5QWK+q8d2AHugN8TAkqZxJK0tJ+cJoX2lE+0vH0Kg0=";
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
