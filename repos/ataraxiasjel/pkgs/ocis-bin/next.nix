{ stdenv, lib, fetchurl, autoPatchelfHook }:
stdenv.mkDerivation rec {
  pname = "ocis-next-bin";
  version = "5.0.1";

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
      x86_64-linux = "sha256-Fz0ee0Lu0CL3xJbsp1CCl0rsN/p48BdOj8oVOf0QSh4=";
      aarch64-linux = "sha256-zH7nJi6A1C+AcHc375vaH1VOxIFplR5Hp5AzmANuiOA=";
      i686-linux = "sha256-qrxZ1Kgyb/2C8Rwvg6qH2d1W5F7FT0E8cefAaFfUYIE=";
      x86_64-darwin = "sha256-YxYufX9NL0eYXIoNeYeb0yEIfqVq8laOP7qcy8ZElFY=";
      aarch64-darwin = "sha256-8AEXuwTodhqF0LF1duYItntgp9mxoIdHChbtAnnnaQg=";
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

  # passthru.updateScript = ./update-next.sh;

  meta = with lib; {
    description = "ownCloud Infinite Scale Stack";
    homepage = "https://doc.owncloud.com/ocis/next";
    license = licenses.asl20;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = [ "x86_64-linux" "aarch64-linux" "i686-linux" "x86_64-darwin" "aarch64-darwin" ];
  };
}
