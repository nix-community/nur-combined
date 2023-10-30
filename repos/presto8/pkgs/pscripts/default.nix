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
    rev = "d5a4ad119c16cddd6c21e65f0c91c79211bd2337";
    hash = "sha256-XrUayIYp/GSr2GnlF4cadXZCCIrSXN2defzQxsCmIn8=";
  };

  installPhase = ''
    runHook preInstall

    for exe in pnix pdrives; do
      install -D -m 755 "exe"/"exe" $out/bin/"$exe"
    done

    runHook postInstall
  '';
})
