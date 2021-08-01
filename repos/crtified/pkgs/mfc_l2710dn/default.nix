{ stdenv, pkgsi686Linux, lib, fetchurl, dpkg, makeWrapper, coreutils
, ghostscript, gnugrep, gnused, which, perl }:
let
  srcbase = fetchurl {
    url =
      "https://download.brother.com/welcome/dlf103522/mfcl2710dnpdrv-4.0.0-1.i386.deb";
    sha256 = "1az42769z0zjalzpjvqyh3fmn5qq15y35h41zw47kdzw6j6w59sc";
  };

  basepkg = stdenv.mkDerivation rec {
    name = "mfcl2710dnpdrv-${version}";
    version = "4.0.0-1";

    src = srcbase;

    nativeBuildInputs = [ dpkg makeWrapper ];

    unpackPhase = "dpkg-deb -x $src $out";

    installPhase = ''
      dir=$out/opt/brother/Printers/MFCL2710DN
      date
      substituteInPlace $dir/lpd/lpdfilter \
        --replace /usr/bin/perl ${perl}/bin/perl \
        --replace "BR_PRT_PATH =~" "BR_PRT_PATH = \"$dir\"; #" \
        --replace "PRINTER =~" "PRINTER = \"MFCL2710DN\"; #"
      date
      wrapProgram $dir/lpd/lpdfilter \
        --prefix PATH : ${
          lib.makeBinPath [ coreutils ghostscript gnugrep gnused which ]
        }
      date

      # need to use i686 glibc here, these are 32bit proprietary binaries
      interpreter=${pkgsi686Linux.glibc}/lib/ld-linux.so.2
      patchelf --set-interpreter "$interpreter" $dir/lpd/i686/brprintconflsr3
      patchelf --set-interpreter "$interpreter" $dir/lpd/i686/rawtobr3

      ln -s $dir/lpd/i686/{rawtobr3,brprintconflsr3} $dir/lpd/
    '';

    meta = {
      description = "Brother MFC-L2710DN lpr driver";
      homepage = "http://www.brother.com/";
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" "i686-linux" ];
    };
  };

in stdenv.mkDerivation rec {
  name = "mfcl2710dncupswrapper-${version}";
  version = "4.0.0-1";

  src = srcbase;

  nativeBuildInputs = [ dpkg makeWrapper ];

  unpackPhase = "dpkg-deb -x $src $out";

  installPhase = ''
    basedir=${basepkg}/opt/brother/Printers/MFCL2710DN
    dir=$out/opt/brother/Printers/MFCL2710DN

    substituteInPlace $dir/cupswrapper/lpdwrapper \
      --replace /usr/bin/perl ${perl}/bin/perl \
      --replace "basedir =~" "basedir = \"$basedir\"; #" \
      --replace "\`cp " "\`cp --no-preserve=mode,ownership " \
      --replace "PRINTER =~" "PRINTER = \"MFCL2710DN\"; #"

    substituteInPlace $dir/cupswrapper/paperconfigml2 \
      --replace /usr/bin/perl ${perl}/bin/perl

    wrapProgram $dir/cupswrapper/lpdwrapper  \
      --prefix PATH : ${lib.makeBinPath [ coreutils gnugrep gnused ]}

    mkdir -p $out/lib/cups/filter
    mkdir -p $out/share/cups/model

    ln $dir/cupswrapper/lpdwrapper $out/lib/cups/filter/brother_lpdwrapper_MFCL2710DN
    ln $dir/cupswrapper/brother-MFCL2710DN-cups-en.ppd $out/share/cups/model
  '';

  meta = {
    description = "Brother MFC-L2710DN CUPS wrapper driver";
    homepage = "http://www.brother.com/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" "i686-linux" ];
  };
}

