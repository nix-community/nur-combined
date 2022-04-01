{ stdenv, lib, fetchFromGitHub, pkg-config, autoconf, automake
, libtool, gtk3, gtk-layer-shell
}:

with lib;

stdenv.mkDerivation rec {
  pname = "gtk-layer-background";
  version = "unstable-2022-04-01";

  src = fetchFromGitHub {
    owner = "wmww";
    repo = "gtk-layer-background";
    rev = "45f869a294a93a92a5648e062ad92eaf5237fb11";
    sha256 = "sha256-fF8Q1F4CyWEil7aBHA3aeNfWrCQQeo4/JNQYQtBhSUs=";
  };

  nativeBuildInputs = [ pkg-config autoconf automake libtool ];

  buildInputs = [ gtk3 gtk-layer-shell ];

  preConfigure = "./autogen.sh";

  enableParallelBuilding = true;

  meta = {
    description = "Simple wayland desktop background";
    longDescription = ''
      A desktop background Wayland client using Layer Shell.
    '';
    license = licenses.mit;
    platforms = platforms.linux;
    homepage = https://github.com/wmww/gtk-layer-background;
    maintainers = with maintainers; [ ilya-fedin ];
  };
}
