{
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation(finalAttrs: {
  pname = "pscripts";
  version = "2024-05-24";

  src = fetchFromGitHub {
    owner = "presto8";
    repo = "pscripts";
    rev = "899b89f641c8924dddb5b5c665a83cfe85a0285d";
    hash = "sha256-Ri5Qj9UMscC+svQWKGR7GzIPDLnBz1RSEpct++Ciepo=";
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
