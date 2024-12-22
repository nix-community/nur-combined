{
  lib,
  stdenv,
  fetchurl,
  gtk2-x11,
  pkg-config,
  python3,
  gfortran,
  lesstif,
  cfitsio,
  getopt,
  perl,
  groff,
  which,
  darwin,
  ncurses,
}:

let
  python3Env = python3.withPackages (
    ps: with ps; [
      numpy
      setuptools
    ]
  );
in

stdenv.mkDerivation rec {
  version = "4.4-01";
  pname = "imager";

  src = fetchurl {
    url = "https://dave.oasu.u-bordeaux.fr:5000/5964614a-44f2-47fd-ba18-5f155543044e/imager-last.tgz";
    sha256 = "sha256-cIgsj/OYzi8UZc9Gk/0bN3vHD8Kh+y1+EAPzM4J7t+4=";
  };

  nativeBuildInputs = [
    pkg-config
    groff
    perl
    getopt
    gfortran
    which
  ];

  buildInputs = [
    gtk2-x11
    lesstif
    cfitsio
    python3Env
    ncurses
  ] ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [ CoreFoundation ]);

  patches =
    [
      ./wrapper.patch
      ./python-ldflags.patch
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin ([
      ./clang.patch
      ./cpp-darwin.patch
    ]);

  NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-unused-command-line-argument";

  # Workaround for https://github.com/NixOS/nixpkgs/issues/304528
  env.GAG_CPP = lib.optionalString stdenv.hostPlatform.isDarwin "${gfortran.outPath}/bin/cpp";

  NIX_LDFLAGS = lib.optionalString stdenv.isDarwin (
    with darwin.apple_sdk.frameworks; "-F${CoreFoundation}/Library/Frameworks"
  );

  configurePhase = ''
    substituteInPlace admin/wrapper.sh --replace '%%OUT%%' $out
    substituteInPlace admin/wrapper.sh --replace '%%PYTHONHOME%%' ${python3Env}
    substituteInPlace utilities/main/gag-makedepend.pl --replace '/usr/bin/perl' ${perl}/bin/perl
    source admin/gildas-env.sh -c gfortran -o openmp
    echo "gag_doc:        $out/share/doc/" >> kernel/etc/gag.dico.lcl
  '';

  postInstall = ''
    mkdir -p $out/bin
    cp -a ../gildas-exe/* $out
    mv $out/$GAG_EXEC_SYSTEM $out/libexec
    cp admin/wrapper.sh $out/bin/imager
    chmod 755 $out/bin/imager
  '';

  meta = {
    description = "Interferometric imaging package";
    longDescription = ''IMAGER is an interferometric imaging package in the GILDAS software, tailored for usage simplicity and efficiency for multi-spectral data sets. IMAGER was developed and optimized to handle large data files. Therefore, IMAGER works mostly on internal buffers and avoids as much as possible saving data to intermediate files. File saving is done ultimately once the data analysis process is complete, which offers an optimum use of the disk bandwidth.'';
    homepage = "https://imager.oasu.u-bordeaux.fr";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.smaret ];
    platforms = lib.platforms.all;
  };

}
