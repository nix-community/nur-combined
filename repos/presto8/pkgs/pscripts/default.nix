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
    rev = "e550833d94b1fb8297ecdb71f545ba79c9441195";
    hash = "sha256-vsHkfJ+0sFAbDb2nk2+fAMYpBwquBuzyEvwjzxVSS7U=";
  };

  installPhase = ''
    runHook preInstall

    for exe in lastf pdrives pfs phash pmove pnix psg; do
      install -D -m 755 "$exe"/"$exe" $out/bin/"$exe"
    done

    runHook postInstall
  '';
})
