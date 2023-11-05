{
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation(finalAttrs: {
  pname = "pscripts";
  version = "2023-10-29";

  src = fetchFromGitHub {
    owner = "presto8";
    repo = "pscripts";
    rev = "d7e294f14a995bc5bf28280d73c3236fe5f15e18";
    hash = "sha256-bgL5TlGxigYwSiVHvJwrt7nawN3KIjTEy+qgtwErV6g=";
  };

  installPhase = ''
    runHook preInstall

    for exe in pnix pdrives pmove; do
      install -D -m 755 "$exe"/"$exe" $out/bin/"$exe"
    done

    runHook postInstall
  '';
})
