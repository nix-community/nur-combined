{pkgsi686Linux, lib, stdenv, fetchurl, cups, dpkg, gnused, makeWrapper, ghostscript, file, a2ps, coreutils, gawk}:

let
  version = "1.1.1-5";
  model = "hl4150cdn";

  cupsdeb = fetchurl {
    url = "https://download.brother.com/welcome/dlf005942/${model}cupswrapper-1.1.1-5.i386.deb";
    sha256 = "sha256:0p76g9v79j6dpk8m41rxms6c52166zs6q5v0qlr0av79dijv8c9w";
  };

  srcdir = "${model}cupswrapper-src-1.1.1-5";
  cupssrc = fetchurl {
    url = "https://download.brother.com/welcome/dlf006745/${srcdir}.tar.gz";
    sha256 = "sha256:14ybkzpay8xcylmdvxir4j7vfc1xnkkcbv9w9zgbfq9206c67s2r";
  };

  lprdeb = fetchurl {
    url = "https://download.brother.com/welcome/dlf005940/${model}lpr-1.1.1-5.i386.deb";
    sha256 = "sha256:1i0ckpfh662d52jfzblhhxjlwfwqrdpzsnx1higiycbpf9r7v29i";
  };
in
  pkgsi686Linux.stdenv.mkDerivation {
    name = "cups-brother-${model}";
    nativeBuildInputs = [ makeWrapper dpkg ];
    buildInputs = [ cups ghostscript a2ps ];

    unpackPhase = ''
      tar -xvf ${cupssrc}
    '';

    buildPhase = ''
      gcc -Wall ${srcdir}/brcupsconfig/brcupsconfig.c -o brcupsconfpt1
    '';

    installPhase = ''

      # install lpr
      dpkg-deb -x ${lprdeb} $out

      substituteInPlace $out/usr/local/Brother/Printer/${model}/lpd/filter${model} \
      --replace /usr/local "$out/usr/local"

      substituteInPlace $out/usr/local/Brother/Printer/${model}/inf/setupPrintcapij \
      --replace /usr/local "$out/usr/local"

      sed -i '/GHOST_SCRIPT=/c\GHOST_SCRIPT=gs' $out/usr/local/Brother/Printer/${model}/lpd/psconvertij2

      # need to use i686 glibc here, these are 32bit proprietary binaries
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/usr/local/Brother/Printer/${model}/lpd/br${model}filter
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/usr/bin/brprintconf_${model}

      wrapProgram $out/usr/local/Brother/Printer/${model}/lpd/psconvertij2 \
      --prefix PATH ":" ${ lib.makeBinPath [ gnused coreutils gawk ] }

      wrapProgram $out/usr/local/Brother/Printer/${model}/lpd/filter${model} \
      --prefix PATH ":" ${ lib.makeBinPath [ ghostscript a2ps file gnused coreutils ] }

      dpkg-deb -x ${cupsdeb} $out

      substituteInPlace $out/usr/local/Brother/Printer/${model}/cupswrapper/cupswrapper${model} \
      --replace /usr/local "$out/usr/local"

      mkdir -p $out/lib/cups/filter
      ln -s $out/usr/local/Brother/Printer/${model}/cupswrapper/cupswrapper${model} $out/lib/cups/filter/cupswrapper${model}

      mkdir -p $out/share/cups/model
      ln -s $out/usr/local/Brother/Printer/${model}/cupswrapper/${model}.ppd $out/share/cups/model/${model}.ppd


      cp brcupsconfpt1 $out/usr/local/Brother/Printer/${model}/cupswrapper/
      ln -s $out/usr/local/Brother/Printer/${model}/cupswrapper/brcupsconfpt1 $out/lib/cups/filter/brcupsconfpt1

      ln -s $out/usr/local/Brother/Printer/${model}/lpd/filter${model} $out/lib/cups/filter/brlpdwrapper${model}

      wrapProgram $out/usr/local/Brother/Printer/${model}/cupswrapper/cupswrapper${model} \
      --prefix PATH ":" ${ lib.makeBinPath [ gnused coreutils gawk ] }
    '';

    meta = {
      homepage = "http://www.brother.com/";
      description = "Brother hl4150cdn printer driver";
      license = lib.licenses.unfree;
      platforms = lib.platforms.linux;
      downloadPage = "https://support.brother.com/g/b/producttop.aspx?c=eu_ot&lang=en&prod=hl4150cdn_all";
    };
  }
