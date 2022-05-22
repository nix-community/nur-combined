{ appimageTools, fetchurl, lib, gsettings-desktop-schemas, gtk3, makeDesktopItem }:

let
  pname = "joplin-desktop";
  version = "2.8.8";
  desktopItem = makeDesktopItem {
     name = "Joplin";
     exec = "joplin-desktop";
     type = "Application";
     desktopName = "Joplin";
  };
in appimageTools.wrapType2 rec {
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://github.com/laurent22/joplin/releases/download/v${version}/Joplin-${version}.AppImage";
    sha256 = "0ivljlw6kdpg94q9syi11zmk54w06m8j3zicx9nppqg720fw4zv3";
  };

  profile = ''
    export LC_ALL=C.UTF-8
    export XDG_DATA_DIRS=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS
  '';

  multiPkgs = null; # no 32bit needed
  extraPkgs = appimageTools.defaultFhsEnvArgs.multiPkgs;
  extraInstallCommands = ''
    mkdir -p $out/share/applications
    ln -s ${desktopItem}/share/applications/* $out/share/applications
    mv $out/bin/{${name},${pname}}
  '';


  meta = with lib; {
    description = "Prereleases: An open source note taking and to-do application with synchronisation capabilities";
    longDescription = ''
      Joplin is a free, open source note taking and to-do application, which can
      handle a large number of notes organised into notebooks. The notes are
      searchable, can be copied, tagged and modified either from the
      applications directly or from your own text editor. The notes are in
      Markdown format.
    '';
    homepage = "https://joplinapp.org";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = [ "x86_64-linux" ];
  };
}
