{ stdenv, fetchgit, libX11, libXinerama, libXft, xlibs, patches ? [], header_config_file ? null }:

with stdenv.lib;
let
  customConfig = if header_config_file == null then "" else ''cp ${header_config_file} config.h'';
in
  stdenv.mkDerivation rec {
    name = "dwm";
    version = "1.0";

    src = fetchgit {
      url = "https://github.com/LukeSmithXYZ/dwm";
      rev = "ad08183a60d259387955c8e5f5f319cc5b8a19c9";
      sha256 = "12a9mhbk06hpllc2fqipr37vn2qwxd7xlqf1xyd6g72fjwvmp1w4";
    };

    buildInputs = [ libX11 libXinerama libXft xlibs.libXext.dev ];

    prePatch = ''
      sed -i "s@/usr/local@$out@" config.mk
    ''
    + customConfig;

    inherit patches;

    buildPhase = ''make LDFLAGS="-L/usr/X11R6/lib -lX11 -lXinerama -lfontconfig -lXft -lX11-xcb -lxcb -lxcb-res -lXext"'';

    meta = {
      homepage = "https://github.com/LukeSmithXYZ/dwm";
      description = "Luke's build of dwm";
      license = stdenv.lib.licenses.mit;
      platforms = with stdenv.lib.platforms; all;
    };
  }
