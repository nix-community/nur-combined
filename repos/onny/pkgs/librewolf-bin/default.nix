{ appimageTools, makeDesktopItem, fetchurl, gsettings-desktop-schemas, gtk3 }:

let
  pname = "librewolf-bin";
  version = "80.0.1-1";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://gitlab.com/librewolf-community/browser/linux/uploads/24558402cfe45771dad61f0e7e1ec1b6/LibreWolf-${version}.x86_64.AppImage";
    sha256 = "0xd7mjwz28yzr4i5p6da6n0wc922fjsiziprqfrdqbvz3wpz454d";
  };

  appimageContents = appimageTools.extractType2 { inherit name src; };
  in appimageTools.wrapType2 {
    inherit name src;

    # Fix for file dialog crash
    profile = ''
      export LC_ALL=C.UTF-8
      export XDG_DATA_DIRS=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS
    '';

    extraInstallCommands = ''
      mv $out/bin/${name} $out/bin/${pname}
  '';
}

