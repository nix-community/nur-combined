{ stdenv, appimageTools, fetchurl }:
let
  pname = "pineapple";
  version = "1013";
  name = "Yuzu-EA-${version}";

  src = fetchurl {
    url = "https://github.com/pineappleEA/pineappleEA.github.io/releases/download/EA-${version}/${name}.AppImage";
    sha256 = "051ms0dbyl128dcjibrnphkgif0h802jzzjp1jnhcm917jqlawv1";
  };

  appimageContents = appimageTools.extractType2 { inherit name src; };
in appimageTools.wrapType2 {
  inherit name src;

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/yuzu
    install -m 444 -D ${appimageContents}/yuzu.desktop $out/share/applications/yuzu.desktop
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  meta = with stdenv.lib; {
    description = "Early Access builds for yuzu";
    homepage = "https://pineappleEA.github.io";
    license = with licenses; [ 
      gpl2Only 
      # Icons
      cc-by-nd-30 cc0
    ];
    maintainers = [ maintainers.ivar ];
    platforms = [ "x86_64-linux" ];
  };
}
