{ lib
, stdenvNoCC
, fetchurl
, undmg
, gitUpdater
,
}:
stdenvNoCC.mkDerivation rec {
  pname = "insomnium";
  version = "0.2.2";

  src = fetchurl {
    url = "https://github.com/ArchGPT/insomnium/releases/download/core@${version}/Insomnium.CoreMacOS-${version}.dmg";
    sha256 = "sha256-kedT9Uup2ngZz0TFwYkL4V4z7+vEqGouSmwaJPfmo20=";
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
