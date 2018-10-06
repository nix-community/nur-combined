{ stdenv, buildPythonApplication, fetchPypi
, glibcLocales
, aioh2, aiohttp, dnspython, aiohttp-remotes }:

buildPythonApplication rec {
  pname = "doh-proxy";
  version = "0.0.8";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0mfl84mcklby6cnsw29kpcxj7mh1cx5yw6mjs4sidr1psyni7x6c";
  };


  checkInputs = [ glibcLocales ];
  preCheck = ''
    export LC_ALL="en_US.UTF-8";
  '';

  propagatedBuildInputs = [
    aioh2 aiohttp dnspython aiohttp-remotes
  ];

  meta = with stdenv.lib; {
    description = "DNS-Over-HTTPS proxy";
    homepage = "https://github.com/facebookexperimental/doh-proxy";
    license = licenses.bsd3;
  };
}
