{
  appimageTools,
  callPackage,
  lib,
  makeWrapper,
  source ? callPackage ./source.nix { },
}:

let
  pname = "yesplaymusic";
  inherit (source) version src;

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  nativeBuildInputs = [ makeWrapper ];

  extraInstallCommands = ''
    wrapProgram $out/bin/${pname} --add-flags --no-sandbox

    install -Dm444 ${appimageContents}/yesplaymusic.desktop \
      $out/share/applications/yesplaymusic.desktop
    substituteInPlace $out/share/applications/yesplaymusic.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox' 'Exec=${pname}'

    install -Dm444 \
      ${appimageContents}/usr/share/icons/hicolor/512x512/apps/yesplaymusic.png \
      $out/share/icons/hicolor/512x512/apps/yesplaymusic.png
  '';

  meta = {
    description = "Third-party NetEase Cloud Music player";
    homepage = "https://github.com/qier222/YesPlayMusic";
    changelog = "https://github.com/qier222/YesPlayMusic/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
  };
}
