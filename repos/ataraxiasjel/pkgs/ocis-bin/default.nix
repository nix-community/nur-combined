{ stdenv, lib, fetchurl, autoPatchelfHook }:
stdenv.mkDerivation (finalAttrs: {
  pname = "ocis-bin";
  version = "6.0.0";

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
      x86_64-linux = "sha256-gF5RIEbWrD912kSAXiVgovZN3bGOvQDZDYkar2azpBQ=";
      aarch64-linux = "sha256-51MnjUea64rxgnj6P1Pl3m/VQwnDB6//uPTz8VYI93g=";
      i686-linux = "sha256-wP5ObJVhHnifPhHVWvuKZ1W1sSlEjca/MSydYjb9CTo=";
      x86_64-darwin = "sha256-8NizERBNlGH13pgtaSOIwYg49VSf9K9DOzngR8ng7N8=";
      aarch64-darwin = "sha256-qcXpUudyTMOExkqIJub6qvC4gpiawg8kOJ68qp+xm9g=";
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
