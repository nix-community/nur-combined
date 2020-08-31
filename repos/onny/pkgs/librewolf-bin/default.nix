{ appimageTools, makeDesktopItem, fetchurl }:

let
  pname = "librewolf-bin";
  version = "80.0-1";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://gitlab.com/librewolf-community/browser/linux/uploads/af5efe6553d8e34b76c0bc844d77832f/LibreWolf-${version}.x86_64.AppImage";
    sha256 = "00bc7y8f157jfyyh34b8vp3hc9d9cia9m5mb5qww4qw5f4h1vj5b";
  };

  appimageContents = appimageTools.extractType2 { inherit name src; };
  in appimageTools.wrapType2 {
    inherit name src;
    extraInstallCommands = ''
      mv $out/bin/${name} $out/bin/${pname}
  '';
}

