{ appimageTools, makeDesktopItem, fetchurl, wrapGAppsHook }:

let
  pname = "librewolf-bin";
  version = "80.0.1-1";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://gitlab.com/librewolf-community/browser/linux/uploads/24558402cfe45771dad61f0e7e1ec1b6/LibreWolf-${version}.x86_64.AppImage";
    sha256 = "0xd7mjwz28yzr4i5p6da6n0wc922fjsiziprqfrdqbvz3wpz454d";
  };

  nativeBuildInputs = [ wrapGAppsHook ];

  appimageContents = appimageTools.extractType2 { inherit name src; };
  in appimageTools.wrapType2 {
    inherit name src;
    extraInstallCommands = ''
      mv $out/bin/${name} $out/bin/${pname}
  '';
}

