{
  appimageTools,
  fetchurl,
}:
let
  pname = "steam-art-manager";
  version = "3.11.0";

 
  src = fetchurl {
    url = "https://github.com/Tormak9970/Steam-Art-Manager/releases/download/v${version}/steam-art-manager.AppImage";
    sha256 = "0891rswbp4a5px4f9s7mkjxp5lrhfnyhfy7jnvqyks0md0r09zyx";
  };

  appimageContents = appimageTools.extractType1 { inherit pname version src; };
in 
appimageTools.wrapType2 rec {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/app.desktop -T $out/share/applications/${pname}.desktop
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=app' 'Exec=WEBKIT_DISABLE_COMPOSITING_MODE=1 WEBKIT_DISABLE_DMABUF_RENDERER=1 steam-art-manager'
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Icon=app' 'Icon=sam'

    mkdir $out/share/icons
    cp -r ${appimageContents}/app.png $out/share/icons/sam.png
  '';

  # TODO: Wrap so I can properly add the environment variables.
  
  meta.description = "Simple and elegant Steam library customization";
}
