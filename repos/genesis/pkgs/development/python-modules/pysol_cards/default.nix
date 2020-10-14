{ stdenv, fetchPypi, buildPythonPackage, pbr, random2, six }:

buildPythonPackage rec {
  pname   = "pysol_cards";
  version = "0.10.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "15v20h2a2xlnxnb69svrpddjscw45alg6s08i360404xhkjwfspa";
  };

  propagatedBuildInputs = [ pbr random2 six ];

  ## Need to fix test deps, relies on stestr and a few other packages that aren't available on nixpkgs
  #checkInputs = [ testtools pytest ];
  doCheck = false;

  meta = with stdenv.lib; {
    homepage = https://github.com/shlomif/pysol_cards;
    description = "allow the python developer to generate the initial deals of some PySol FC games";
    license = licenses.mit; # expat version
    maintainers = with maintainers; [ genesis ];
  };

}
