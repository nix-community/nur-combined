{ pkgsi686Linux, lib, stdenv, fetchurl
, dpkg, makeWrapper
, ghostscript, gnused, perl, coreutils, gnugrep, which
}:

let
  model = "dcpt720dw";
  version = "3.5.0";
  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf105179/dcpt720dwpdrv-3.5.0-1.i386.deb";
    sha256 = "sha256-ToUFGnHxd6rnLdfhdDGzhvsgFJukEAVzlm79hmkSV3E=";
  };
  reldir = "opt/brother/Printers/${model}/";
in
rec {
  driver = pkgsi686Linux.stdenv.mkDerivation {
    pname = "${model}-lpr";
    inherit src version;

    nativeBuildInputs = [ dpkg makeWrapper ];
    unpackPhase = "dpkg-deb -x $src $out";

    installPhase = ''
      dir="$out/${reldir}"
      substituteInPlace $dir/lpd/filter_${model} \
        --replace /usr/bin/perl ${perl}/bin/perl \
        --replace "BR_PRT_PATH =~" "BR_PRT_PATH = \"$dir\"; #" \
        --replace "PRINTER =~" "PRINTER = \"${model}\"; #"
      wrapProgram $dir/lpd/filter_${model} \
        --prefix PATH : ${lib.makeBinPath [
          coreutils ghostscript gnugrep gnused which
        ]}

      patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
        $dir/lpd/i686/br${model}filter
      patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
        $dir/lpd/x86_64/br${model}filter
    '';

    meta = with lib; {
      homepage = "http://www.brother.com/";
      description = "Brother ${model} printer driver";
      sourceProvenance = with sourceTypes; [ binaryNativeCode ];
      license = licenses.unfree;
      platforms = platforms.linux;
      downloadPage = "https://support.brother.com/g/b/downloadlist.aspx?c=ru&lang=ru&prod=dcpt720dw_all&os=127";
      maintainers = with maintainers; [ suhr ];
    };
  };

  cupswrapper = stdenv.mkDerivation {
    pname = "${model}-cupswrapper";
    inherit src version;

    nativeBuildInputs = [ dpkg makeWrapper ];
    unpackPhase = "dpkg-deb -x $src $out";

    installPhase = ''
      basedir=${driver}/${reldir}
      dir=$out/${reldir}
      substituteInPlace $dir/cupswrapper/brother_lpdwrapper_${model} \
        --replace /usr/bin/perl ${perl}/bin/perl \
        --replace "basedir =~" "basedir = \"$basedir\"; #" \
        --replace "PRINTER =~" "PRINTER = \"${model}\"; #"
      wrapProgram $dir/cupswrapper/brother_lpdwrapper_${model} \
        --prefix PATH : ${lib.makeBinPath [ coreutils gnugrep gnused ]}
      mkdir -p $out/lib/cups/filter
      mkdir -p $out/share/cups/model
      ln $dir/cupswrapper/brother_lpdwrapper_${model} $out/lib/cups/filter
      ln $dir/cupswrapper/brother_${model}_printer_en.ppd $out/share/cups/model
    '';

    meta = with lib; {
      homepage = "http://www.brother.com/";
      description = "Brother ${model} printer CUPS wrapper driver";
      sourceProvenance = with sourceTypes; [ binaryNativeCode ];
      license = licenses.unfree;
      platforms = platforms.linux;
      downloadPage = "https://support.brother.com/g/b/downloadlist.aspx?c=ru&lang=ru&prod=dcpt720dw_all&os=127";
      maintainers = with maintainers; [ suhr ];
    };
  };
}
