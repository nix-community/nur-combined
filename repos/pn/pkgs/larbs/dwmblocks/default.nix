{ stdenv, fetchgit, libX11, patches ? [] }:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "dwmblocks";

  src = fetchgit {
    url = "https://github.com/LukeSmithXYZ/dwmblocks";
    rev = "6bbb413fd7fb31b052945061305bf9ac87f0f6fd";
    sha256 = "0h62avawlkbxjkhjsbzp5afrd5jbjjvnzq73nh3p53p1zpjc18wb";
  };

  inherit patches;

  buildInputs = [ libX11 ];

  installPhase = ''
    make install PREFIX=$out
  '';

  meta = {
    homepage = "https://github.com/LukeSmithXYZ/dwmblocks";
    description = "Luke's build of dwmblocks";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
