{
  appimageTools,
  fetchurl,
  icu,
  lib,
}:

let
  pname = "rootapp";
  version = "0.9.79";

  src = fetchurl {
    url = "https://installer.rootapp.com/installer/Linux/X64/Root.AppImage";
    hash = "sha256-EAVd8u9diCIpmXfzfvC9tMKJeH+xIS0fkgkQ06uj8C4=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: [ icu ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/Root.desktop $out/share/applications/${pname}.desktop
    install -m 444 -D ${appimageContents}/Root.png $out/share/icons/hicolor/512x512/apps/${pname}.png

    substituteInPlace $out/share/applications/${pname}.desktop \
    	--replace-fail 'Exec=Root' 'Exec=${pname} %U'
  '';

  meta = {
    broken = true; # I'm marking this as broken, as the hash of the URL isn't fixed
    changelog = "https://www.rootapp.com/changelog";
    description = "Nix implementation of Root";
    homepage = "https://rootapp.com";
    license = lib.licenses.unfree;
    mainProgram = "rootapp";
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
