{
  stdenv
  ,fetchFromGitHub
  ,lib
  ,xorg
  ,libconfig
  ,libdrm
  ,libGL
  ,dbus
  ,pcre
  ,gnumake
  ,pkg-config
  ,bash
  ,asciidoc
  ,libev
  ,uthash
}:

stdenv.mkDerivation
{
  name = "compton";
  src = fetchFromGitHub
  {
    owner = "tryone144";
    repo = "compton";
    rev = "241bbc50285e58cbc6a25d45066689eeea913880";
    sha256 = "148s7rkgh5aafzqdvag12fz9nm3fxw2kqwa8vimgq5af0c6ndqh2";
  };
  hardeningDisable = [ "format" ];
  buildInputs = 
  [
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXfixes
    xorg.libXext
    xorg.libXrender
    xorg.libXrandr
    xorg.libXinerama
    xorg.xorgproto
    xorg.xprop
    xorg.xwininfo
    xorg.xcbutilrenderutil
    xorg.xcbutilimage
    xorg.pixman
    uthash
    libconfig
    libdrm
    libGL
    dbus
    pcre
    pkg-config
    bash
    asciidoc
    libev
    gnumake
  ];
  buildPhase = 
  ''
    mkdir $out
    cd $out
    mkdir build
    cd build
    cp $src/* . -r
    make
  '';
  installPhase =
  ''
    cd $out
    mkdir bin
    cp build/compton bin
    chmod 777 build -R
    rm build -rf
    ln -sf $out/bin/compton $out/bin/picom
  '';
  meta = with lib; {
    description = "A compositor for X11 (fork with excellent blur)";
    homepage = "https://github.com/tryone144/compton";
    license = licenses.mit;
    maintainers = with maintainers; [ dan4ik605743 ];
    platforms = platforms.linux;
  };
}
