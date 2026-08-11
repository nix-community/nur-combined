/*
nix-build -E 'with import <nixpkgs> { }; callPackage ./default.nix { }'

based on
nixpkgs/pkgs/misc/cups/drivers/brother/mfcl3770cdw/default.nix

usage
  services.printing.enable = true;
  services.printing.drivers =
    let
      hll3210cw = nur.repos.milahu.brother-hll3210cw;
    in
    [
      hll3210cw.driver
      hll3210cw.cupswrapper
      pkgs.gutenprint
      pkgs.gutenprintBin
    ]
  ;

TODO merge driver and cupswrapper into one derivation?
*/

{ pkgsi686Linux
, stdenv
, fetchurl
, dpkg
, makeWrapper
, coreutils
, ghostscript
, gnugrep
, gnused
, which
, perl
, lib
}:

let
  model = "hll3210cw";
  version = "1.0.2-0";
  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf103923/${model}pdrv-${version}.i386.deb";
    sha256 = "hdRmDZ1FEbcdI6miAs4BZDey0WrzdUkHrbkf67N095s=";
  };
  reldir = "opt/brother/Printers/${model}/";
  metaBase = {
    homepage = "http://www.brother.com/";
    platforms = [ "x86_64-linux" "i686-linux" ];
    #maintainers = [ lib.maintainers.steveej ];
  };

in rec {
  driver = pkgsi686Linux.stdenv.mkDerivation rec {
    inherit src version;
    pname = "${model}drv";

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
    # need to use i686 glibc here, these are 32bit proprietary binaries
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $dir/lpd/br${model}filter
    '';

    meta = metaBase // {
      description = "Brother ${lib.strings.toUpper model} driver";
      license = lib.licenses.unfree;
    };
  };

  cupswrapper = stdenv.mkDerivation rec {
    inherit version src;
    pname = "${model}cupswrapper";

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

    meta = metaBase // {
      description = "Brother ${lib.strings.toUpper model} CUPS wrapper driver";
      license = lib.licenses.gpl2;
      # TODO where is the source?
    };
  };
}
