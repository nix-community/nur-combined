{ lib, stdenv, fetchurl
, dpkg, makeWrapper
, cups, ghostscript, a2ps, gawk
, gnused, file, coreutils, gnugrep, which
}:

let
  version = "3.5.0";
  model = "dcpt720dw";
in
rec {
  driver = stdenv.mkDerivation {
    pname = "${model}-lpr";
    inherit version;

    src = fetchurl {
      url = "https://download.brother.com/welcome/dlf105179/dcpt720dwpdrv-3.5.0-1.i386.deb";
      sha256 = "sha256-ToUFGnHxd6rnLdfhdDGzhvsgFJukEAVzlm79hmkSV3E=";
    };

    nativeBuildInputs = [ dpkg makeWrapper ];
    buildInputs = [ cups ghostscript a2ps gawk ];
    unpackPhase = "dpkg-deb -x $src $out";

    installPhase = ''
      substituteInPlace $out/opt/brother/Printers/${model}/lpd/filter_${model} \
        --replace /opt "$out/opt"

      patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
        $out/opt/brother/Printers/${model}/lpd/i686/br${model}filter
      patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
        $out/opt/brother/Printers/${model}/lpd/x86_64/br${model}filter

      mkdir -p $out/lib/cups/filter/
      ln -s $out/opt/brother/Printers/${model}/lpd/filter_${model} \
        $out/lib/cups/filter/brother_lpdwrapper_${model}

      wrapProgram $out/opt/brother/Printers/${model}/lpd/filter_${model} \
        --prefix PATH ":" ${lib.makeBinPath [
          gawk ghostscript a2ps file gnused gnugrep coreutils which
        ]}
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
    inherit version;

    src = fetchurl {
      url = "https://download.brother.com/welcome/dlf105179/dcpt720dwpdrv-3.5.0-1.i386.deb";
      sha256 = "sha256-ToUFGnHxd6rnLdfhdDGzhvsgFJukEAVzlm79hmkSV3E=";
    };

    nativeBuildInputs = [ dpkg makeWrapper ];
    buildInputs = [ cups ghostscript a2ps gawk ];
    unpackPhase = "dpkg-deb -x $src $out";

    installPhase = ''
      for f in $out/opt/brother/Printers/${model}/cupswrapper/cupswrapper${model}; do
        wrapProgram $f --prefix PATH : ${lib.makeBinPath [ coreutils ghostscript gnugrep gnused ]}
      done

      mkdir -p $out/share/cups/model
      ln -s $out/opt/brother/Printers/${model}/cupswrapper/brother_${model}_printer_en.ppd \
        $out/share/cups/model/
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
