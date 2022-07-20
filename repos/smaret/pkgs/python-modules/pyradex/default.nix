{ stdenv
, lib
, fetchgit
, fetchurl
, buildPythonPackage
, numpy
, requests # not sure this is needed
, astropy
, astroquery
, gfortran
}:

buildPythonPackage rec {
  pname = "pyradex";
  version = "0.4.2.dev0";

  srcs = [
    (
      fetchgit {
        url = "https://github.com/keflavich/pyradex.git";
        rev = "f8c8e745241238f8ad709efa4ada22fe082c503c";
        sha256 = "1dyihdkzxky0g4jd9k74q7niclpj0qr1g7rvpmlnd3hj01hfy9zs";
      }
    )
    (
      fetchurl {
        url = "https://personal.sron.nl/~vdtak/radex/radex_public.tar.gz";
        sha256 = "168rlqnhgf1z6sd8dag3gwfbh5d9z6kxddxf8m16bac2mk2y7lls";
      }
    )
  ];
  sourceRoot = "pyradex-f8c8e74";

  postUnpack = "ln -s ../Radex $sourceRoot/Radex";

  postPatch = ''
    substituteInPlace setup.py --replace "install_radex.install_radex()" "install_radex.install_radex(download=False, extract=False)" 
  '';

  nativeBuildInputs = [ gfortran numpy ];

  propagatedBuildInputs = [ numpy astropy astroquery requests ];

  checkInputs = [ astroquery ];

  configurePhase = "python setup.py install_radex install_myradex";

  # TODO: Fix tests
  doCheck = false;

  preCheck = "export HOME=$TMPDIR";

  meta = with lib; {
    description = "Python interface to RADEX";
    homepage = https://github.com/keflavich/pyradex;
    # TODO: Fix package
    broken = true;
    license = licenses.bsd3;
    platforms = platforms.all;
    maintainers = [ maintainers.smaret ];
  };
}
