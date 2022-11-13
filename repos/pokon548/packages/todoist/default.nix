{ appimageTools, lib, fetchurl, gtk3, gsettings-desktop-schemas}:

# Based on zettlr nixpkgs
let
  pname = "todoist";
  version = "1.0.9";
  name = "${pname}-${version}";
  src = fetchurl {
    url = "https://electron-dl.todoist.com/linux/Todoist-${version}.AppImage";
    sha256 = "sha256-DfNFDiGYTFGetVRlAjpV/cdWcGzRDEGZjR0Dc9aAtXc=";
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
    mv $out/bin/${name} $out/bin/${pname}
    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  meta = with lib; {
    description = "The official Todoist electron app";
    homepage = "https://todoist.com";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
  };
}