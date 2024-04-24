{ lib
, stdenvNoCC
, fetchurl
, undmg
, gitUpdater
,
}:
stdenvNoCC.mkDerivation rec {
  pname = "kap";
  version = "3.6.0";
  arch = "amd64";

  src = fetchurl {
    url = "https://github.com/wulkano/kap/releases/download/v${version}/Kap-${version}-${arch}.dmg";
    sha256 = "sha256-D0tp1f1OxZ2ntuFTciMUyT3CY9srgcDQGR4lY2BHPOM=";
  };

  sourceRoot = ".";

  preferLocalBuild = true;
  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    mv Kap.app $out/Applications

    runHook postInstall
  '';

  passthru.updateScript = gitUpdater {
    url = "https://github.com/wulkano/kap";
    rev-prefix = "v";
  };

  meta = with lib; {
    description = "An open-source screen recorder built with web technology";
    homepage = "https://getkap.co";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = platforms.darwin;
    maintainers = with maintainers; [ jpts ];
    license = licenses.mit;
  };
}
