{
  lib,
  stdenvNoCC,
  appimageTools,
  fetchurl,
}:

let
  pname = "t3code";
  version = "0.0.45";

  sources = {
    x86_64-linux = {
      arch = "x86_64";
      hash = "sha256-q3sKhtHqZXzMFitgt3LGH3C8fIueJZtGk51Tuzj6oCo=";
    };
    aarch64-linux = {
      arch = "arm64";
      hash = "sha256-AxE1ZvUrB6TVAyOcN4VAF1aR2aBX7UHg55SJfWvgVNU=";
    };
  };

  srcInfo =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-${srcInfo.arch}.AppImage";
    inherit (srcInfo) hash;
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
(appimageTools.wrapType2 {
  inherit pname version src;

  profile = ''
    if [ -z "''${SSL_CERT_FILE:-}" ]; then
      if [ -f /etc/ssl/certs/ca-certificates.crt ]; then
        export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
      elif [ -f /etc/ssl/certs/ca-bundle.crt ]; then
        export SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt
      fi
    fi
  '';

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp -r ${appimageContents}/usr/share/icons $out/share/
    cp ${appimageContents}/t3code.desktop $out/share/applications/
    substituteInPlace $out/share/applications/t3code.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=t3code %U'
  '';

  meta = {
    description = "Desktop control surface for local coding agents";
    homepage = "https://github.com/pingdotgg/t3code";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "t3code";
  };
}).overrideAttrs (_: {
  preferLocalBuild = false;
})
