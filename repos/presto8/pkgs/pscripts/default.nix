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
    rev = "3063b09e2f721b1832fa054f442b556052c48725";
    hash = "sha256-PY8TjnBvUFEz0uST62vmb+py0jBXkJaVsboc1ua6eoU=";
  };

  installPhase = ''
    runHook preInstall

    for exe in pnix pdrives pmove; do
      install -D -m 755 "$exe"/"$exe" $out/bin/"$exe"
    done

    runHook postInstall
  '';
})
