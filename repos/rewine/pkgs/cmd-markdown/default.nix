{ lib
, stdenv
, fetchurl
, glib
, gtk2
, alsa-lib
, freetype
, libnotify
, fontconfig
, nss
, gnome2
, cairo
, pango
, libudev0-shim
, xorg
, makeWrapper
, autoPatchelfHook
}:
stdenv.mkDerivation {
  pname = "cmd-markdown";
  version = "2017-01-14";

  src = fetchurl {
    url = "http://static.zybuluo.com/cmd_markdown_linux64.tar.gz";
    sha256 = "sha256-7jAvD0nS8gQNd2TY5XLNMmGwD6gx6lEhz6drQZwJg20=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [ 
    glib
    gtk2
    alsa-lib
    freetype
    libnotify
    fontconfig.lib
    nss
    cairo
    pango
    gnome2.GConf
    xorg.libXi
    xorg.libXcursor
    xorg.libXext
    xorg.libXfixes
    xorg.libXtst
    xorg.libXdamage
    xorg.libXrender
    xorg.libXcomposite
    xorg.libXrandr
    libudev0-shim
  ];
  
  installPhase = ''
    mkdir -p $out/bin
    mv * $out/ 
    ln -s $out/'Cmd Markdown' $out/bin/cmdmarkdown
  '';

  preFixup = let
    runtimeLibs = lib.makeLibraryPath [ libudev0-shim ];
  in ''
    wrapProgram "$out/bin/cmdmarkdown" --prefix LD_LIBRARY_PATH : ${runtimeLibs}
  '';
 
  dontStrip = true;

  meta = with lib; {
    description = "An easy to use markdown editor";
    homepage = "https://www.zybuluo.com";
    license = licenses.unfree;
    platforms = [ "x86_64-linux"];
  };
}

