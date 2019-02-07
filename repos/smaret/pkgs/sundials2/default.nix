{ cmake, fetchurl, python, stdenv }:

stdenv.mkDerivation rec {

  pname = "sundials";
  version = "2.7.0";

  src = fetchurl {
    url = "https://computation.llnl.gov/projects/${pname}/download/${pname}-${version}.tar.gz";
    sha256 = "01513g0j7nr3rh7hqjld6mw0mcx5j9z9y87bwjc16w2x2z3wm7yk";
  };

  preConfigure = ''
    export cmakeFlags="-DCMAKE_INSTALL_PREFIX=$out -DEXAMPLES_INSTALL_PATH=$out/share/examples $cmakeFlags"
  '';

  nativeBuildInputs = [ cmake ];
  buildInputs = [ python ];

  meta = with stdenv.lib; {
    description = "Suite of nonlinear differential/algebraic equation solvers";
    homepage    = https://computation.llnl.gov/projects/sundials;
    platforms   = platforms.all;
    maintainers = [ maintainers.smaret ];
    license     = licenses.bsd3;
  };

}
