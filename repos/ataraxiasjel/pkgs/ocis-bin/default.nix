{ stdenv, lib, fetchurl, autoPatchelfHook }:
stdenv.mkDerivation (finalAttrs: {
  pname = "ocis-bin";
  version = "6.1.0";

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
      x86_64-linux = "sha256-O/08Kj4O/UFomY8cmpzn0AdaS1gl6QvToeHlE/W9lYw=";
      aarch64-linux = "sha256-I47II7FNEPbbjJmZYuiFecHEuYJB9oqfrVL2Dw2YOj0=";
      i686-linux = "sha256-ptKUNtV8J9l4Dr2vIkm97zqZQ9STlk6ul1KMNhX8jfE=";
      x86_64-darwin = "sha256-RtyG59K/PUgI4SG5VsoGMUkZIBz0jSVCkxBB7HTi10w=";
      aarch64-darwin = "sha256-qC68zeXddeoa6t26TZX8YSXVeT2ljxeJTTl9ytXflHE=";
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

  passthru.updateScript = ./update.sh;

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
