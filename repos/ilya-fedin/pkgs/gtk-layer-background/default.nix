{ stdenv, lib, fetchFromGitHub, pkg-config, autoconf, automake
, libtool, gtk3, gtk-layer-shell
}:

with lib;

stdenv.mkDerivation rec {
  pname = "gtk-layer-background";
  version = "unstable-2019-08-01";

  src = fetchFromGitHub {
    owner = "wmww";
    repo = "gtk-layer-background";
    rev = "c8af4694f4b831af5870cd956b29183b308ad231";
    sha256 = "AOeZ0wQiQCBo1Dr/K/Odk/7344fV7bWQ6AmIEmd3Xfw=";
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
