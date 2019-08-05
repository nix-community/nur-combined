{ stdenvNoCC, fetchzip, mkfontdir, mkfontscale }:

let
  version = "1.11.4"; 
in stdenvNoCC.mkDerivation {
  name = "tamzen-font";
  inherit version;

  src = fetchzip {
    url = "https://github.com/sunaku/tamzen-font/archive/Tamzen-${version}.tar.gz";
    sha256 = "17kgmvg6q32mqhx9g44hjvzv0si0mnpprga4z7na930g2zdd8846";
  };

  nativeBuildInputs = [ mkfontdir mkfontscale ];

  phases = ["installPhase"];
  installPhase = ''
    install -Dm0644 -t $out/share/fonts/tamzen/ $src/pcf/*.pcf
    install -Dm0644 -t $out/share/consolefonts/ $src/psf/*.psf

    cd $out/share/fonts/tamzen/
    mkfontdir
    mkfontscale
  '';

  meta = with stdenvNoCC.lib; {
    description = "Bitmapped programming font, based on Tamsyn";
    homepage = https://github.com/sunaku/tamzen-font;
    downloadPage = https://github.com/sunaku/tamzen-font/releases;
    license = licenses.free;
    platforms = platforms.linux;
  };
}
