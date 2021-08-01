{ lib
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "graph-cli";
  version = "0.1.13";

  src = python3Packages.fetchPypi {
    inherit version;
    pname = "graph_cli";
    sha256 = "04bp1y29rx3nlam4g233xcmbcbc7v3ihpbymi4m7bh7qi6qmvs39";
  };
  
  propagatedBuildInputs = with python3Packages; [ matplotlib pandas ];

  doCheck = true;

  meta = with lib; {
    description = "Rtree: spatial index for Python GIS";
    homepage = "https://rtree.readthedocs.io/en/latest/";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
