{ lib, stdenv, fetchurl, gtk2-x11 , pkg-config , python3 , gfortran , lesstif
, cfitsio , getopt , perl , groff , which, darwin, ncurses
}:

let
  python3Env = python3.withPackages(ps: with ps; [ numpy setuptools ]);
in

stdenv.mkDerivation rec {
  version = "4.2-08";
  pname = "imager";

  src = fetchurl {
    url = "https://nuage.oasu.u-bordeaux.fr/index.php/s/PoxdxMTTYXqNwKF/download?path=%2F&files=imager-oct24.tar.gz";
    sha256 = "sha256-leICO1RT+AURV7/2CJ6IPC6e4KynfrW6yO1In80LVWI=";
  };

  nativeBuildInputs = [ pkg-config groff perl getopt gfortran which ];

  buildInputs = [ gtk2-x11 lesstif cfitsio python3Env ncurses ]
    ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [ CoreFoundation ]);

  # FIXME: Which of these patches are still needed?
  #patches = [ ./wrapper.patch ./clang.patch ./aarch64.patch ./python-ldflags.patch ];
  patches = [ ./wrapper.patch ];

  NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-unused-command-line-argument";

  NIX_LDFLAGS = lib.optionalString stdenv.isDarwin (with darwin.apple_sdk.frameworks; "-F${CoreFoundation}/Library/Frameworks");

  configurePhase=''
    substituteInPlace admin/wrapper.sh --replace '%%OUT%%' $out
    substituteInPlace admin/wrapper.sh --replace '%%PYTHONHOME%%' ${python3Env}
    substituteInPlace utilities/main/gag-makedepend.pl --replace '/usr/bin/perl' ${perl}/bin/perl
    source admin/gildas-env.sh -c gfortran -o openmp
    echo "gag_doc:        $out/share/doc/" >> kernel/etc/gag.dico.lcl
  '';
  
  postInstall=''
    mkdir -p $out/bin
    cp -a ../gildas-exe/* $out
    mv $out/$GAG_EXEC_SYSTEM $out/libexec
    cp admin/wrapper.sh $out/bin/imager
    chmod 755 $out/bin/imager
  '';

  meta = {
    description = "Interferometric imaging package";
    longDescription = ''
      IMAGER is an interferometric imaging package in the GILDAS software, tailored for usage simplicity and efficiency for multi-spectral data sets. IMAGER was developed and optimized to handle large data files. Therefore, IMAGER works mostly on internal buffers and avoids as much as possible saving data to intermediate files. File saving is done ultimately once the data analysis process is complete, which offers an optimum use of the disk bandwidth.'';
    homepage = "https://imager.oasu.u-bordeaux.fr";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.smaret ];
    platforms = lib.platforms.all;
    broken = stdenv.isDarwin && stdenv.isAarch64;
  };

}
