{ appimageTools, lib, fetchurl, gtk3, gsettings-desktop-schemas}:

# Based on zettlr nixpkgs
let
  pname = "obsidian";
  version = "0.9.22";
  name = "${pname}-${version}";
  src = fetchurl {
    url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v${version}/Obsidian-${version}.AppImage";
    sha256 = "193y4gskwcafrp6xf2i4wbl4619bikr5wkky2nwp628zybb3p420";
  };
  appimageContents = appimageTools.extractType2 {
    inherit name src;
  };
in appimageTools.wrapType2 rec {
  inherit name src;

  profile = ''
    export XDG_DATA_DIRS=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS
  '';

  multiPkgs = null; # no 32bit needed
  extraPkgs = appimageTools.defaultFhsEnvArgs.multiPkgs;
  extraInstallCommands = ''
    mv $out/bin/{${name},${pname}}
    install -m 444 -D ${appimageContents}/obsidian.desktop $out/share/applications/obsidian.desktop
    install -m 444 -D ${appimageContents}/obsidian.png $out/share/icons/hicolor/512x512/apps/obsidian.png
    substituteInPlace $out/share/applications/obsidian.desktop --replace 'Exec=AppRun' 'Exec=${pname}'
  '';

  meta = with lib; {
    description = "Obsidian is a both a Markdown editor and a knowledge base app.";
    homepage = "https://obsidian.md/";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
  };
}

