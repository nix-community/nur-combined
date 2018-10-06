{ stdenv, buildPythonPackage, fetchPypi
, notebook, matplotlib, lesscpy }:

buildPythonPackage rec {
  pname = "jupyterthemes";
  version = "0.19.6";

  propagatedBuildInputs = [ notebook matplotlib lesscpy ];

  src = fetchPypi {
    inherit pname version;
    sha256 = "14ypp2i3q7dkhndh55yqygk1fkiz2gryk6vn6w3flyc3ynpfmjfp";
  };

  meta = with stdenv.lib; {
    description = "Custom Jupyter Notebook Themes";
    homepage = https://github.com/dunovank/jupyter-themes;
    license = licenses.mit;
  };
}
