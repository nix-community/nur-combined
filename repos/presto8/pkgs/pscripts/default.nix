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
    rev = "504a8e2ae7925296587e6fd7fa96a375cf5f7436";
    hash = "sha256-MhRUigEelGxdYZ/PW4Owy8950QCmiS/FRmXUNFe16Go=";
  };

  installPhase = ''
    runHook preInstall

    for exe in pnix pdrives pmove; do
      install -D -m 755 "$exe"/"$exe" $out/bin/"$exe"
    done

    runHook postInstall
  '';
})
