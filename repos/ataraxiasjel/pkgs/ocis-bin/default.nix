{ stdenv, lib, fetchurl, autoPatchelfHook }:
stdenv.mkDerivation (finalAttrs: {
  pname = "ocis-bin";
  version = "6.2.0";

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
      x86_64-linux = "sha256-PwMyNOzFpz/3zstnFpnzTklM9F9AUGjLhI8a7iAUEYo=";
      aarch64-linux = "sha256-74a6pVv+WTV9YYEzF9L2BHFGgHUnFjRLCZLalSbrXmk=";
      i686-linux = "sha256-BpiFVvjHIKxxNn/69geiUJ2wzW4S5yz0E90i1fyFjFk=";
      x86_64-darwin = "sha256-IJty9a2TsLd+7WysAi7i45drMPiAybM7Gzk3LJTC4AQ=";
      aarch64-darwin = "sha256-SFA7mTIE+bWz8Ryk2Jv5XfdE5AOhfjWlCJK8XYQ7CgU=";
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
