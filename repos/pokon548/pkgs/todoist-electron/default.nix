{ appimageTools, lib, fetchurl, electron, makeWrapper, libsecret }:

let
  pname = "todoist-electron";
  version = "8.4.3";
  name = "Todoist-${version}";

  src = lib.warn
    "${name} from pokon548's NUR is deprecated and will be removed from NUR repo soon. Migrate by changing nur.repos.pokon548.todoist-electron to pkgs.todoist-electron"
    fetchurl {
      url =
        "https://electron-dl.todoist.com/linux/Todoist-linux-x86_64-${version}.AppImage";
      sha256 = "sha256-TYZUaIH1bedPgZOa5FHG+pBbUOCQ2Hyj/Tm0BKSAvlc=";
    };

  appimageContents = appimageTools.extract { inherit name src; };

in appimageTools.wrapType2 {
  inherit version name src;

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}
    install -m 444 -D ${appimageContents}/todoist.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/todoist.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  passthru.version = version;

  extraPkgs = pkgs: with pkgs; [ libsecret libappindicator-gtk3 ];

  meta = with lib; {
    homepage = "https://todoist.com";
    description = "The official Todoist electron app";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
  };
}
