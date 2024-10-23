{
  lib,
  gcc11Stdenv,
  fetchurl,
  autoconf,
  tk,
  tcl,
  otcl,
  tclcl,
  xorg,
  libpcap,
  perl,
}: let
  version = "2.35";
in
  gcc11Stdenv.mkDerivation {
    inherit version;

    name = "ns2-${version}";

    src = fetchurl {
      url = "http://sourceforge.net/projects/nsnam/files/ns-2/${version}/ns-src-${version}.tar.gz";
      sha256 = "11r35q8w3v8wi0q3s3kdd5kswpnib5smfi558982azgcphqyhcia";
    };

    patches = map fetchurl (import ./debian-patches.nix) ++ [./nix_nixnode.patch ./disable_memdebug.patch];
    CXXFLAGS = "-std=c++98";

    postPatch = ''
      substituteInPlace conf/configure.in.tk \
        --replace-fail 'TK_H_PLACES_D="$d' 'TK_H_PLACES_D="${tk.dev}/include'
    '';

    # do not build the conflicting tools/random.cc file
    # running full autoreconf breaks an existing autoconf.h.in
    preConfigure = ''
      sed -i -e 's/tools\/random.o//g' Makefile.in makefile.vc allinone/install
      ${autoconf}/bin/autoconf -f
    '';

    # add CXX flags to use c++98
    # fix up case insensitive file system issues
    # (version vs VERSION)
    postConfigure = ''
      substituteInPlace Makefile \
        --replace-fail '$(CPP)' '$(CPP) $(CXXFLAGS)'
      mv VERSION NS_VERSION
      substituteInPlace Makefile \
        --replace-fail 'VERSION' 'NS_VERSION'
    '';

    configureFlags = [
      "--with-tcl=${tcl}"
      "--with-tcl-ver=${tcl.release}"
      "--with-tk=${tk}"
      "--with-tk-ver=${tk.release}"
      "--with-otcl=${otcl}"
      "--with-tclcl=${tclcl}"
    ];

    nativeBuildInputs = [
      perl
      libpcap
      xorg.libX11
      xorg.libXt
      xorg.libXext
    ];

    preInstall = ''
      mkdir -p $out/bin
    '';

    # do not install nse or nstk
    # postInstall = ''
    #   install -t $out/bin nse nstk
    # '';

    meta = {
      description = "A discrete event simulator targeted at networking research";
      homepage = https://www.isi.edu/websites/nsnam/ns/;
      license = with lib.licenses; [bsdOriginal bsd3 asl20 gpl2];
    };
  }
