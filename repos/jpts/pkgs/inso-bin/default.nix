{ lib
, stdenvNoCC
, fetchurl
, unzip
, gitUpdater
, darwin
}:
stdenvNoCC.mkDerivation rec {
  pname = "inso-cli";
  version = "8.3.0";

  # single x86-64 binary, no arm support yet
  src = fetchurl {
    url = "https://github.com/Kong/insomnia/releases/download/lib@${version}/inso-macos-${version}.zip";
    sha256 = "sha256-6PLyQSgLKjykq9sr4QmPWJ0ueoyu8jdEBCRtHm5YcqY=";
  };

  sourceRoot = ".";

  preferLocalBuild = true;
  nativeBuildInputs = [ unzip ];

  # dont invalidate sig
  dontFixup = true;
  #dontStrip = false;

  installPhase = ''
    runHook preInstall

    install -Dm755 inso $out/bin/inso

    runHook postInstall
  '';

  passthru.updateScript = gitUpdater {
    url = "https://github.com/Kong/insomnia";
    rev-prefix = "lib@";
  };

  meta = with lib; {
    description = "The open-source, cross-platform API client for GraphQL, REST, WebSockets and gRPC.";
    homepage = "https://github.com/Kong/insomnia";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = platforms.darwin;
    maintainers = with maintainers; [ jpts ];
    license = licenses.mit;
  };
}
