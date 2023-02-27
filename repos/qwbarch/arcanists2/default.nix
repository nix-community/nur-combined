{ pkgs, lib, stdenv, autoPatchelfHook, makeWrapper }:

let
  version = "21254e_1fda44cb280f4146a4e471ac46995c81";
  description = "Turn-based multiplayer strategy game";
  desktopEntry = ''
    [Desktop Entry]
    Type=Application
    Version=${version}
    Name=Arcanists 2
    GenericName=${description}
    Icon=/share/applications/arcanists2.png
    Exec=arcanists2
    Terminal=false
    Categories=Game
  '';
in
stdenv.mkDerivation
{
  inherit version;

  name = "arcanist2";
  src = pkgs.fetchzip {
    url = "https://400c3bfb-51ec-4397-aa27-28b8f8c30ca3.filesusr.com/archives/${version}.zip?dn=LinuxArcanists%202.zip";
    sha256 = "b73shcHwpYxT1nHi3SGiGFa1LZXXkV6egV3tzbarQYQ=";
    stripRoot = false;
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = with pkgs; [ steam-run-native ];

  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/lib
    mkdir -p $out/bin
    mkdir -p $out/share/applications
    cp -a $src/. $out/lib
    chmod +x $out/lib/"Arcanists 2.x86_64"
    makeWrapper ${pkgs.steam-run-native}/bin/steam-run $out/bin/arcanists2 --add-flags "$out/lib/'Arcanists 2.x86_64'"
    echo '${desktopEntry}' >> $out/share/applications/arcanists2.desktop
    cp $src/"Arcanists 2_Data"/Resources/UnityPlayer.png $out/share/applications/arcanists2.png
    substituteInPlace $out/share/applications/arcanists2.desktop --replace /share/ $out/share/
  '';

  meta = with lib; {
    inherit description;
    homepage = "https://www.arcanists2.com";
    platforms = platforms.linux;
    license = licenses.unfree;
  };
}
