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
    rev = "0ae0f54b49060dff597f9ebf6b56578daa9977b2";
    hash = "sha256-Sy6h5zHGQW9jOJK8EM0bTHo1JOKtLMsV0KuA+YNEo0s=";
  };

  installPhase = ''
    runHook preInstall

    for exe in lastf pdrives pfs phash pmove pnix psg; do
      install -D -m 755 "$exe"/"$exe" $out/bin/"$exe"
    done

    runHook postInstall
  '';
})
