{ stdenv, lib, fetchurl, autoPatchelfHook }:
stdenv.mkDerivation rec {
  pname = "ocis-next-bin";
  version = "5.0.0-rc.5";

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
      x86_64-linux = "sha256-rdKCPlJb0BV9nBq0neoIFn9e97A5zL7il1v23I9Hqm0=";
      aarch64-linux = "sha256-p8w+3APWqbuUVP6yoGwPL2npXXz3QuawD8AUdSl7D04=";
      i686-linux = "sha256-Vyuef6QGHSLmr12aPqQLWBsJ5KPumA++/H5vyan/FCM=";
      x86_64-darwin = "sha256-iveA2ZufsiX2IzHPRkVKKckQKLsxfNQL5W6UDZG3LG4=";
      aarch64-darwin = "sha256-xIg4P12C/0+GNEy18+af0T9MqXlPYvVSLuRfnpFBX4Q=";
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

  passthru.updateScript = ./update-next.sh;

  meta = with lib; {
    description = "ownCloud Infinite Scale Stack";
    homepage = "https://doc.owncloud.com/ocis/next";
    license = licenses.asl20;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = [ "x86_64-linux" "aarch64-linux" "i686-linux" "x86_64-darwin" "aarch64-darwin" ];
  };
}
