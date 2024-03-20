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
    rev = "d39f35ef23a796164dc5934d5917ac29ff07b08e";
    hash = "sha256-F0PUzk2RaZk6H8Wcq/UMHrnuKpfd0Zprst5HFuQy1RE=";
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
