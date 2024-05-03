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
    rev = "f4c72a82816c088e667b5fa1dc5216baed435c2f";
    hash = "sha256-sRSSluapA0VvnDS9oWpd4Y1SlaLLtLqmqb1EJsVgEMQ=";
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
