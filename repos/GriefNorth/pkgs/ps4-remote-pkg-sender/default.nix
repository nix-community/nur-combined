{
  lib,
  appimageTools,
  fetchurl,
  makeWrapper,
}:

let
  version = "2.10.4";
  pname = "ps4-remote-pkg-sender";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://github.com/Gkiokan/ps4-remote-pkg-sender/releases/download/v${version}/PS4.Remote.PKG.Sender.V2-${version}.AppImage";
    hash = "sha256-jpYs3heFPqELhjC01wp09pHWkrWSaZdnK9NPANCqzpc=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 rec {
  inherit pname version src;

  nativeBuildInputs = [ makeWrapper ];

  extraInstallCommands = ''
    install -Dm644 ${appimageContents}/ps4remotepkgsenderv2.desktop \
      $out/share/applications/${pname}.desktop
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} --no-sandbox %U' \
      --replace-fail 'Icon=ps4remotepkgsenderv2' 'Icon=${pname}'

    install -Dm644 ${appimageContents}/usr/share/icons/hicolor/0x0/apps/ps4remotepkgsenderv2.png \
      $out/share/icons/hicolor/512x512/apps/${pname}.png

    # electron 8's chrome-sandbox is not setuid here, so the SUID sandbox
    # helper refuses to start; fall back to chromium's own sandbox.
    wrapProgram "$out/bin/${pname}" \
      --add-flags "--no-sandbox"
  '';

  meta = {
    description = "Manage and send PKG files to your PS4 and PS5";
    homepage = "https://github.com/iref-use/ps4-remote-pkg-sender";
    # no license file upstream
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
