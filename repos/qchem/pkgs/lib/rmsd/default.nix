{ buildPythonPackage, lib, fetchPypi, scipy }:
buildPythonPackage rec {
    pname = "rmsd";
    version = "1.4";

    propagatedBuildInputs = [ scipy ];

    src = fetchPypi  {
      inherit pname version;
      sha256 = "0gsncsszya1zp2yw777f46df2a3wk80d8np5c4ihzalzj5glma0n";
    };

    meta = with lib; {
      description = "Calculate root-mean-square deviation (RMSD) between two sets of cartesian coordinates";
      homepage = "https://github.com/charnley/rmsd";
      license = licenses.bsd2;
      platforms = platforms.linux;
      maintainers = [ maintainers.sheepforce ];
    };
  }
