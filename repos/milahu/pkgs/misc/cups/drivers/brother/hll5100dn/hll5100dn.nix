{ lib
, stdenv
, fetchurl
, dpkg
, makeWrapper
, autoPatchelfHook
, coreutils
, ghostscript
, gnugrep
, gnused
, which
, perl
}:

let
  make = "brother";
  model = "hll5100dn";
  version = "3.5.1-1";

  modelUpper = lib.strings.toUpper model;
  modelDir = modelUpper;
  reldir = "opt/brother/Printers/${modelDir}";

  # https://support.brother.com/g/b/downloadtop.aspx?c=us&lang=en&prod=hll5100dn_us_eu_as
  srcs = {
    driver = rec {
      # https://download.brother.com/welcome/dlf102553/hll5100dnlpr-3.5.1-1.i386.deb
      inherit model version reldir;
      suffix = "lpr";
      dlf = "dlf102553";
      url = "https://download.brother.com/welcome/${dlf}/${model}${suffix}-${version}.i386.deb";
      sha256 = "sha256-JnPiBVJ+ZJKivjq+Kizcf5U8vilOFdLVWBuRUiWJ5zE=";
    };
    wrapper = rec {
      # https://download.brother.com/welcome/dlf102554/hll5100dncupswrapper-3.5.1-1.i386.deb
      inherit model version reldir;
      suffix = "cupswrapper";
      dlf = "dlf102554";
      url = "https://download.brother.com/welcome/${dlf}/${model}${suffix}-${version}.i386.deb";
      sha256 = "sha256-i309lhjE6FTNd8f0d4vv7/oaNUt165scU9Gzlff8gcE=";
    };
  };

  fixupPerlScripts = ''
    fixupPerlScripts() {
      local path=$1
      local basedir=$2
      local modelDir=$3
      shift 3
      for script in "$@"; do
        echo "fixupPerlScripts: fixing script: $script"
        sed -i '
            s|^my $basedir\s*=.*;$|my $basedir = "'$basedir'";|;
            s|^$basedir\s*=~.*;$||;
            s|^my $PRINTER\s*=.*;$|my $PRINTER = "'$modelDir'";|;
            s|^$PRINTER\s*=~.*;$||;
          ' $script
        wrapProgram $script \
          --prefix PATH : $path \
          --set LANG C
      done
    }
  '';

  platformDirMap = {
    "x86_64-linux" = "x86_64";
    "i686-linux" = "i686";
    "armv7l-linux" = "armv7l";
  };

  platformDir = platformDirMap.${stdenv.hostPlatform.system};
in

stdenv.mkDerivation rec {
  inherit version;
  pname = "${make}-${model}-${suffix}";
  inherit (srcs.wrapper) suffix;

  src = fetchurl {
    inherit (srcs.wrapper) url sha256;
  };

  inherit (driver) nativeBuildInputs buildInputs unpackPhase;

  runtimeDeps = [
    coreutils
    gnugrep
    gnused
  ];

  driver = stdenv.mkDerivation rec {
    inherit version;
    pname = "${make}-${model}-${suffix}";
    inherit (srcs.driver) suffix;

    src = fetchurl {
      inherit (srcs.driver) url sha256;
    };

    nativeBuildInputs = [
      dpkg
      makeWrapper
      autoPatchelfHook
    ];

    buildInputs = [
      perl
    ];

    runtimeDeps = [
      coreutils
      ghostscript
      gnugrep
      gnused
      which
    ];

    unpackPhase = "dpkg-deb -x $src $out";

    installPhase = ''
      dir=$out/${reldir}
      subdir=$dir/lpd
      basedir=$out/${reldir}

      ${fixupPerlScripts}

      fixupPerlScripts \
        ${lib.makeBinPath runtimeDeps} \
        $basedir \
        ${modelDir} \
        $subdir/*lpdfilter*

      chmod -R +x $subdir
      mv $subdir/${platformDir}/* $subdir
      rm -rf $subdir/{${builtins.concatStringsSep "," (builtins.attrValues platformDirMap)}}
    '';

    meta = with lib; {
      description = "Brother ${modelUpper} driver";
      homepage = "http://www.brother.com/";
      sourceProvenance = with sourceTypes; [ binaryNativeCode ];
      license = licenses.unfree;
      platforms = builtins.attrNames platformDirMap;
      maintainers = with maintainers; [ ];
    };
  };

  installPhase = ''
    dir=$out/${reldir}
    subdir=$dir/${suffix}
    basedir=${driver}/${reldir}

    # this file is expected by "cupsFilter" in the PPD file
    mv $subdir/*lpdwrapper* $subdir/brother_lpdwrapper_${modelUpper}

    chmod +x $subdir/*lpdwrapper*
    chmod +x $subdir/*paperconfig* || true

    ${fixupPerlScripts}

    fixupPerlScripts \
      ${lib.makeBinPath runtimeDeps} \
      $basedir \
      ${modelDir} \
      $subdir/*lpdwrapper*

    echo patching the PPD file: $subdir/*.ppd
    # make the name consistent with other brother drivers
    # example:
    # - Brother HLL6400DW
    # + Brother HL-L6400DW
    sed -i -E 's/(Brother ${
        builtins.substring 0 2 (modelUpper)
      })(${
        builtins.substring 2 999 (modelUpper)
      })/\1-\2/g' $subdir/*.ppd

    mkdir -p $out/lib/cups/filter
    ln -s -v $subdir/*lpdwrapper* $out/lib/cups/filter

    mkdir -p $out/share/cups/model
    ln -s -v $subdir/*.ppd $out/share/cups/model
  '';

  meta = with lib; {
    description = "Brother ${modelUpper} CUPS wrapper driver";
    homepage = "http://www.brother.com/";
    license = licenses.gpl2;
    platforms = platforms.all;
    maintainers = with maintainers; [ ];
  };
}
