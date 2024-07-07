{ lib
, python3Packages
}:

python3Packages.buildPythonPackage rec {
  pname = "graph-cli";
  version = "0.1.19";

  src = python3Packages.fetchPypi {
    inherit version;
    pname = "graph_cli";
    sha256 = "sha256-AOfUgeVgcTtuf5IuLYy1zFTBCjWZxu0OiZzUVXDIaSc=";
  };
  
  propagatedBuildInputs = with python3Packages; [ matplotlib pandas ];

  doCheck = true;

  meta = with lib; {
    description = "CLI utility to create graphs from CSV files";
    homepage = "https://github.com/mcastorina/graph-cli";
    license = licenses.gpl3Plus;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
