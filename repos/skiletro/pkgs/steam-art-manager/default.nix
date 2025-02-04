{
  appimageTools,
  fetchurl,
}:
let
  pname = "steam-art-manager";
  version = "3.10.7";

 
  src = fetchurl {
    url = "https://github.com/Tormak9970/Steam-Art-Manager/releases/download/v${version}/steam-art-manager.AppImage";
    sha256 = "sha256-9IKWxRMIrPTS02G31jWVsH9K4LlJqagEXS6t9/EDiuc=";
  };

  appimageContents = appimageTools.extractType1 { inherit pname version src; };
in 
appimageTools.wrapType2 rec {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/app.desktop -T $out/share/applications/${pname}.desktop
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=run' 'Exec=steam-art-manager'
    cp -r ${appimageContents}/app.png $out/share
  '';
  
  meta.description = "Simple and elegant Steam library customization";
}
