{ stdenv, lib, fetchurl, autoPatchelfHook, nix-update-script }:
stdenv.mkDerivation rec {
  pname = "ocis-bin";
  version = "4.0.5";

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
      x86_64-linux = "sha256-8J/G34fldp8MWEMpbhLNN4c655GqqqhXNrTJ2s0IkuI=";
      aarch64-linux = "sha256-SaRftT01vRd9n8rbQXG4/D/WZXuRqVD7BoZzwqrTHVo=";
      i686-linux = "sha256-ItByxCbC38nnDO1J/HhZR/vRebLEqL2ZKAqQuTOeKjI=";
      x86_64-darwin = "sha256-V27rp7dWb7W0nfkD6oWuxfneQeBxb3kFieRvQH69Sqo=";
      aarch64-darwin = "sha256-X9dg8kTrzglf7Sy3D8ionaSgf4Fh5iC/lYjPF71Fh4E=";
    };
  in fetchurl {
    url =
      "https://github.com/owncloud/ocis/releases/download/v${version}/ocis-${version}-${suffix}";
    inherit sha256;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontStrip = stdenv.isDarwin;

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -D $src $out/bin/ocis
    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "ownCloud Infinite Scale Stack";
    homepage = "https://doc.owncloud.com/ocis/next";
    license = licenses.asl20;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = [ "x86_64-linux" "aarch64-linux" "i686-linux" "x86_64-darwin" "aarch64-darwin" ];
  };
}
