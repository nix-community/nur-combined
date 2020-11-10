{ stdenv, fetchurl, openblas } :

let
  version = "3.8";

in stdenv.mkDerivation {
  pname = "ergoscf";
  inherit version;

  src = fetchurl {
    url = "http://www.ergoscf.org/source/tarfiles/ergo-${version}.tar.gz";
    sha256 = "1s50k2gfs3y6r5kddifn4p0wmj0yk85wm5vf9v3swm1c0h43riix";
  };

  nativeBuildInputs = [ ];
  buildInputs = [ openblas ];

  patches = [ ./math-constants.patch ];

  postPatch = ''
    patchShebangs ./test
  '';

  configureFlags = [
    "--enable-sse-intrinsics"
    "--enable-linalgebra-templates"
    "--enable-performance"
  ];

  LDFLAGS = "-lopenblas";
  CXXFLAGS = "-fopenmp";

  enableParallelBuilding = true;

  OMP_NUM_THREADS = 2; # required for check phase

  doCheck = true;

  doInstallCheck = true;

  installCheckPhase =  ''
    cat > ergoscf.inp << EOINPUT
    set_nthreads(2)
    molecule_inline Angstrom
     O       0.000000  0.000000  0.000000
     H       0.758602  0.000000  0.504284
     H       0.758602  0.000000 -0.504284
    EOF
    basis = "STO-3G"
    run "HF"
    EOINPUT

    $out/bin/ergo ergoscf.inp

    # Energy is different from MOLCAS or Molpro
    grep "74.880174" ergoscf.out
  '';

  meta = with stdenv.lib; {
    description = "Quantum chemistry program for large-scale self-consistent field calculations";
    homepage = http://http://www.ergoscf.org;
    license = licenses.gpl3;
    maintainers = [ maintainers.markuskowa ];
    platforms = platforms.linux;
  };
}

