{ pkgsi686Linux, stdenv, lib, fetchurl, dpkg, makeWrapper, coreutils, gnused
, which, ghostscript, libredirect, file, a2ps, gawk }:

let
  model = "dcpj315w";
  version = "1.1.3-1";
in rec {
  driver = pkgsi686Linux.stdenv.mkDerivation rec {

    name = "${model}lpr";
    inherit version;

    src = fetchurl {
      url = "https://download.brother.com/welcome/dlf005591/${name}-${version}.i386.deb";
      hash = "sha256-sf5kKinMJYPNz6cUFms7f1I4KBFMQetDX9nMubI0zNc=";
    };

    nativeBuildInputs = [ dpkg makeWrapper ];
    unpackPhase = "dpkg-deb -x $src $out";

    installPhase = ''
      dir=$out/opt/brother/Printers/dcpj315w

      substituteInPlace $dir/lpd/filterdcpj315w \
        --replace "BR_PRT_PATH=/" "BR_PRT_PATH=\"$dir\" #"

      wrapProgram $dir/lpd/filterdcpj315w \
        --prefix PATH : ${
          lib.makeBinPath [ coreutils ghostscript gnused which file a2ps ]
        }

      wrapProgram $dir/lpd/psconvertij2 \
        --prefix PATH : ${
          lib.makeBinPath [ coreutils ghostscript gnused which gawk ]
        }

      interpreter=$(cat $NIX_CC/nix-support/dynamic-linker)
      patchelf --set-interpreter "$interpreter" $dir/lpd/brdcpj315wfilter
      patchelf --set-interpreter "$interpreter" $out/usr/bin/brprintconf_dcpj315w

      wrapProgram $out/usr/bin/brprintconf_dcpj315w \
        --set LD_PRELOAD "${libredirect}/lib/libredirect.so" \
        --set NIX_REDIRECTS "/opt/brother=$out/opt/brother"
    '';

    meta = with lib; {
      description = "Brother DCP-J315W LPR driver";
      homepage =
        "https://support.brother.com/g/b/downloadlist.aspx?c=as_ot&lang=en&prod=dcpj315w_eu_as&os=128#SelectLanguageType-559_0_1";
      license = licenses.unfree;
      maintainers = with maintainers; [ c0deaddict ];
      platforms = [ "x86_64-linux" "i686-linux" ];
    };
  };

  cupswrapper = stdenv.mkDerivation rec {
    name = "${model}cupswrapper";
    inherit version;

    src = fetchurl {
      url = "https://download.brother.com/welcome/dlf005593/${name}-${version}.i386.deb";
      hash = "sha256-s3f+rbOWyR9bc9dcrBD+NEXJKrA8cVZGazmqz9FWbHc=";
    };

    nativeBuildInputs = [ dpkg makeWrapper ];
    unpackPhase = "dpkg-deb -x $src $out";

    installPhase = ''
      basedir=${driver}/opt/brother
      dir=$out/opt/brother/Printers/dcpj315w/cupswrapper

      chmod 664 $dir/brother_dcpj315w_printer_en.ppd

      # Below file is based on:
      # $out/opt/brother/Printers/dcpj315w/cupswrapper/cupswrapperdcpj315w
      cp ${./brlpdwrapperdcpj315w} $dir/brlpdwrapperdcpj315w
      chmod 755 $dir/brlpdwrapperdcpj315w

      substituteInPlace $dir/brlpdwrapperdcpj315w \
        --replace "/opt/brother/" "$basedir/" \
        --replace "/usr/share/cups/model/Brother/" "$out/share/cups/model/" \
        --replace "brcupsconfpt1=" "brcupsconfpt1=\"$dir/brcupsconfpt1\"; #"

      wrapProgram $dir/brlpdwrapperdcpj315w \
        --prefix PATH : "${lib.makeBinPath [ coreutils gnused ]}"
      interpreter=$(cat $NIX_CC/nix-support/dynamic-linker)
      patchelf --set-interpreter "$interpreter" $dir/brcupsconfpt1

      wrapProgram $dir/brcupsconfpt1 \
        --prefix PATH : "${driver}/usr/bin"

      mkdir -p $out/lib/cups/filter
      mkdir -p $out/share/cups/model

      ln $dir/brlpdwrapperdcpj315w $out/lib/cups/filter
      ln $dir/brother_dcpj315w_printer_en.ppd $out/share/cups/model
    '';

    meta = with lib; {
      description = "Brother DCP-J315W CUPS wrapper driver";
      homepage = "https://www.brother.com";
      license = licenses.gpl2Plus;
      maintainers = with maintainers; [ c0deaddict ];
      platforms = [ "x86_64-linux" "i686-linux" ];
    };
  };
}
