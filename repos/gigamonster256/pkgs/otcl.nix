{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  xorg,
  tk,
  tcl,
}: let
  version = "1.14";
in
  stdenv.mkDerivation {
    inherit version;
    name = "otcl-${version}";
    src = fetchurl {
      url = "https://sourceforge.net/projects/otcl-tclcl/files/OTcl/${version}/otcl-src-${version}.tar.gz";
      sha256 = "0sdrhavrg9v0wms8a7g8rgmfr80j4j5dr23kshm0hzndgkaawi66";
    };

    CFLAGS = "-DUSE_INTERP_ERRORLINE -DUSE_INTERP_RESULT";

    postPatch = ''
        substituteInPlace conf/configure.in.tk \
          --replace-fail 'TK_H_PLACES_D="$d' 'TK_H_PLACES_D="${tk.dev}/include'
      #   substituteInPlace Makefile.in \
      #     --replace-fail '$(SHLIB_LD)' '"$(SHLIB_LD)"'cat Makefile.in
    '';

    # do not build shared libraries
    postConfigure = ''
      # building
      substituteInPlace Makefile \
          --replace-fail 'all: libotcl.a libotcl$(SHLIB_SUFFIX) otclsh owish' 'all: libotcl.a otclsh owish'
      # installing
      substituteInPlace Makefile \
          --replace-fail 'install: owish otclsh libotcl.a libotcl$(SHLIB_SUFFIX) otcl.h dirs' 'install: owish otclsh libotcl.a otcl.h dirs'
      substituteInPlace Makefile \
          --replace-fail '$(INSTALL) libotcl$(SHLIB_SUFFIX) $(INST_OLIBSH)' ""
    '';

    nativeBuildInputs = [autoreconfHook xorg.libX11 xorg.libXt];

    configureFlags = [
      "--with-tcl=${tcl}"
      "--with-tcl-ver=${tcl.release}"
      "--with-tk=${tk}"
      "--with-tk-ver=${tk.release}"
    ];

    meta = {
      description = "An extension to Tcl/Tk for object-oriented programming";
      homepage = http://otcl-tclcl.sourceforge.net/otcl/;
      license = lib.licenses.free;
    };
  }
