{ appimageTools, makeDesktopItem, fetchurl, gsettings-desktop-schemas, gtk3 }:

let
  pname = "librewolf-bin";
  version = "94.0-1";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://gitlab.com/api/v4/projects/24386000/packages/generic/librewolf/${version}/LibreWolf.x86_64.AppImage";
    sha256 = "sha256-RoZ/Tn3CY95/+E5rkTF/vbuhJQ9EOndmF3P78ciAesY=";
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
