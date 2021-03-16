{ stdenv, lib, fetchgit, libX11, config_h ? null, patches ? [] }:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "dwmblocks";

  src = fetchgit {
    url = "https://github.com/LukeSmithXYZ/dwmblocks";
    rev = "78925115014bea2f4ead26f0dd7f833ff301ad11";
    sha256 = "0239wzydn63964yp69sqdb4q71jcjbvl5gd4y4l46nz8ckk6xnng";
  };

  inherit patches;

  buildInputs = [ libX11 ];

  prePatch = ''
    ${lib.optionalString (config_h != null) "cp ${config_h} config.h"}
  '';

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
