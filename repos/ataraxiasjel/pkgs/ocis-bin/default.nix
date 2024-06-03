{ stdenv, lib, fetchurl, autoPatchelfHook }:
stdenv.mkDerivation (finalAttrs: {
  pname = "ocis-bin";
  version = "5.0.5";

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
      x86_64-linux = "sha256-YAIhtHv/cO4yFpkWoRNMf6t4+ifMtGPTcYu84ZMvfD4=";
      aarch64-linux = "sha256-OdtT9NOhh0Fkk+8CDic0NWWbGflk3FcuKB60OycJU5E=";
      i686-linux = "sha256-4yEgg0Ve8tjNn2weH9d91tfRaU1TE569VvZLxzuzXsw=";
      x86_64-darwin = "sha256-6jaX9iqyqztykeXZX3YqwRV/silFiyfeB9gJyreAfF8=";
      aarch64-darwin = "sha256-KJqMJct7YWocE4eVjMF36adqTIf7WcutZlG3QEoMhCI=";
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
