{ stdenv, fetchurl, autoreconfHook, libelf, tcsh, tcl, publib }:

let
  src = fetchurl {
    url = "http://www.cs.arizona.edu/slinky/slinky.tgz";
    sha256 = "1bdjzskv525ikwqfz6zwd1m8hb0i0gvizr0apc37w3f7gqpf080g";
  };
  version = "2014";

  # use same buildInputs as 'prelink' in tree
  prelinkDeps = [ libelf stdenv.cc.libc (stdenv.lib.getOutput "static" stdenv.cc.libc) ];
  buildInputs = prelinkDeps ++ [ publib tcsh tcl ];

  prelink = stdenv.mkDerivation {
    name = "slinky-prelink${version}";
    inherit src version;

    postUnpack = "export sourceRoot=$sourceRoot/slinky/prelink";

    nativeBuildInputs = [ autoreconfHook ];

    inherit buildInputs;

    hardeningDisable = [ "all" ];
  };

  slinky = stdenv.mkDerivation {
    name = "slinky-${version}";
    inherit src version;

    postUnpack = "export sourceRoot=$sourceRoot/slinky/src";

    nativeBuildInputs = [ autoreconfHook ];

    inherit buildInputs;

    hardeningDisable = [ "all" ];

    #prePatch = ''
    #  substituteInPlace ../prelink/src/gather.c --replace "./ld-linux.so.2" "$(cat $NIX_CC/nix-support/dynamic-linker)"
    #  substituteInPlace ../prelink/src/get.c --replace "./ld-linux.so.2" "$(cat $NIX_CC/nix-support/dynamic-linker)"
    #'';

    meta = with stdenv.lib; {
      description = "Static linking tools";
      homepage = http://slinky.cs.arizona.edu/;
      license = licenses.gpl2Plus;
      maintainers = with maintainers; [ dtzWill ];
      platforms = platforms.all;
    };
  };
in slinky
