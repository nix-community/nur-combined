{ lib
, stdenvNoCC
, fetchurl
, undmg
, gitUpdater
,
}:
stdenvNoCC.mkDerivation rec {
  pname = "insomnium";
  version = "0.2.3-a";

  src = fetchurl {
    url = "https://github.com/ArchGPT/insomnium/releases/download/core@${version}/Insomnium.Core-${version}.signed.dmg";
    sha256 = "sha256-OlYfoNNBPSMYDVSIsANKW7yy1DPkYA4x0ALgyipS2d8=";
  };

  sourceRoot = ".";

  preferLocalBuild = true;
  nativeBuildInputs = [ undmg ];

  # dont invalidate sig
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    mv Insomnium.app $out/Applications

    runHook postInstall
  '';

  passthru.updateScript = gitUpdater {
    url = "https://github.com/ArchGPT/insomnium";
    rev-prefix = "core@";
  };

  meta = with lib; {
    description = "The open-source, cross-platform API client for GraphQL, REST, WebSockets and gRPC.";
    homepage = "https://github.com/ArchGPT/insomnium";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = platforms.darwin;
    maintainers = with maintainers; [ jpts ];
    license = licenses.mit;
  };
}
