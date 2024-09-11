{ stdenv, lib, fetchurl, autoPatchelfHook }:
stdenv.mkDerivation (finalAttrs: {
  pname = "ocis-bin";
  version = "6.3.0";

  src = let
    inherit (stdenv.hostPlatform) system;
    selectSystem = attrs:
      attrs.${system} or (throw "Unsupported system: ${system}");
    suffix = selectSystem {
      x86_64-linux = "linux-amd64";
      aarch64-linux = "linux-arm64";
      i686-linux = "linux-386";
      x86_64-darwin = "darwin-amd64";
      aarch64-darwin = "darwin-arm64";
    };
    sha256 = selectSystem {
      x86_64-linux = "sha256-FHn6KzmgOnx8yqrlCU72T5UL3rBJ26VnJYbNO02hJng=";
      aarch64-linux = "sha256-xma4/t78xVhLaJc7f3zOfRsPr0ZeQXB6tKzZks8lXxQ=";
      i686-linux = "sha256-nTkgv98Rsj7+0RsiyWAdX8G+d2QoPp36FmAumpHqNSY=";
      x86_64-darwin = "sha256-I+cDINpX41lRNIXHzuhbqGtpQ49BnxGwMbZ25DLdOuY=";
      aarch64-darwin = "sha256-m7l4Ksil9XSTIVgI5sVgM/su5dS4QyA1Pm1SDtkkkho=";
    };
  in fetchurl {
    url =
      "https://github.com/owncloud/ocis/releases/download/v${finalAttrs.version}/ocis-${finalAttrs.version}-${suffix}";
    inherit sha256;
  };

  dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -D $src $out/bin/ocis
    runHook postInstall
  '';

  # passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "ownCloud Infinite Scale Stack";
    homepage = "https://owncloud.dev/ocis";
    changelog = "https://github.com/owncloud/ocis/releases/tag/v${finalAttrs.version}";
    license = licenses.unfree;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = [ "x86_64-linux" "aarch64-linux" "i686-linux" "x86_64-darwin" "aarch64-darwin" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    mainProgram = "ocis";
  };
})
