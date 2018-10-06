{ stdenv, buildPythonPackage, fetchPypi, aiohttp }:
buildPythonPackage rec {
  pname = "aiohttp_remotes";
  version = "0.1.2";
  format = "flit";
  
  src = fetchPypi {
    inherit pname version;
    sha256 = "1z53qjpapvgawqspxgrpgvybbd80p51mvpnvnjgz49xsqphzghs3";
  };

  preBuild = ''
    export HOME=$TMP
  '';

  propagatedBuildInputs = [ aiohttp ];

  meta = with stdenv.lib; {
    description = "A set of useful tools for aiohttp.web server";
    homepage = "https://aiohttp-remotes.readthedocs.io";
    license = licenses.mit;
  };
}
