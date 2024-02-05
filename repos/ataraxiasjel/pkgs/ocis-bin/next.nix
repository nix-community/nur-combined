{ stdenv, lib, fetchurl, autoPatchelfHook }:
stdenv.mkDerivation rec {
  pname = "ocis-bin";
  version = "5.0.0-rc.3";

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
      x86_64-linux = "sha256-gaJW9Ul/cJTgYv1pa0JoaHY5NIqDYWN2IxapfjDVAdw=";
      aarch64-linux = "sha256-FLlyWiF2UbPCvcpYNOmXWLCtL3Jktqp8ZBP2XTp/O+U=";
      i686-linux = "sha256-/Qk/bK/+kYgYc8XepXBp/XWR/EtoCcHsY5uH1pAam8Q=";
      x86_64-darwin = "sha256-sdflWISET5448g6ypPRMoAyeWsCYSFKGQ+KT4FDiMuk=";
      aarch64-darwin = "sha256-jDRFJKzxDklsKqBiFipriQqAhXZF+cUmSfSBtpxqhAM=";
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
