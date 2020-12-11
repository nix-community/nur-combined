{ stdenv, fetchgit, libX11, patches ? [] }:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "dwmblocks";

  src = fetchgit {
    url = "https://github.com/LukeSmithXYZ/dwmblocks";
    rev = "5af44b7751814a3eee7ce55f8dc52913e11b0240";
    sha256 = "sha256:00cspmrm6j7w1rakkakv26r501wbczb8admxqn4dmqzg87s6581d";
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
