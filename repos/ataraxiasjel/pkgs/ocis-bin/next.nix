{ stdenv, lib, fetchurl, autoPatchelfHook }:
stdenv.mkDerivation rec {
  pname = "ocis-next-bin";
  version = "5.0.0-rc.4";

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
      x86_64-linux = "sha256-eVsYiDPGItMkVqkAvFykRxJewlcomRBgL283Agid/ig=";
      aarch64-linux = "sha256-UTMTeg20oLtO21WICTfj+aU/BbefjY/7KRZnHh7Q1Cw=";
      i686-linux = "sha256-lnb63m/tjtHdpncr9QJkuF1C2hBdaDNwwK9rH9kCksU=";
      x86_64-darwin = "sha256-7ufr1qRZeGSrfzWga2j/ipT1ILIdqqua64fETx1M1jo=";
      aarch64-darwin = "sha256-3PJyoMpskBpuXbvZhMsdcVxB9tR1Z1CZ9HmEFiEY+Cs=";
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
