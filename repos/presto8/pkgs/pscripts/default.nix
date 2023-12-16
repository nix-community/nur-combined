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
    rev = "b5759649824a4776e73369b16e21262a7983d42a";
    hash = "sha256-hGJsItxqKMqx8ZiUQBiGqZ3Gq6gbPMe0wKO5tf9+4rM=";
  };

  installPhase = ''
    runHook preInstall

    for exe in pnix pdrives pmove; do
      install -D -m 755 "$exe"/"$exe" $out/bin/"$exe"
    done

    runHook postInstall
  '';
})
