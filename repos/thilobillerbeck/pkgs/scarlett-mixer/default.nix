{ stdenv, fetchFromGitHub, pkgs }:

stdenv.mkDerivation rec {
  name = "scarlett-mixer-${version}";
  version = "c181bd28db29ff1813a68be366bd53926bfaaa28";
  src = fetchFromGitHub {
    owner = "x42";
    repo = "scarlett-mixer";
    rev = version;
    sha256 = "08bksn016dliq7l4k8a76wgmjp9332gkc06s4mrdfb9dixhyzc6n";
    fetchSubmodules = true;
  };

  nativeBuildInputs = with pkgs; [
    stdenv
    git
    pkg-config
    pango
    cairo
    lv2
    alsaLib
    mesa
    libGLU
  ];

  installPhase = ''
    mkdir -p $out/bin
    export PREFIX=$out/bin
    make install
    ls
  '';

  meta = with stdenv.lib; {
    description = "Quickly hacked scarlett-mixer GUI for Linux/ALSA";
    homepage = https://github.com/x42/scarlett-mixer;
    license = with licenses; [ gpl2 ];
    platforms = platforms.linux;
  };
}


