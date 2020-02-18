{ stdenv, fetchFromGitHub, python37Packages, pkgs }:

python37Packages.buildPythonApplication rec {
  pname = "colmet";
  version = "0.5.4";
  
  src = fetchFromGitHub {
    owner = "oar-team";
    repo = "colmet";
    rev = "540ddb6aec4c7e262cedbd7f05722d3c919daf25";
    sha256 = "199p5cgg4dhbm8by27968g71sdi6486mc3vx4h66afcvv1xhk34m";
  };

  propagatedBuildInputs = with python37Packages; [
    pyinotify
    pyzmq
    tables
  ];

  # Tests do not pass
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Collecting metrics about process running in cpuset and in a distributed environnement";
    homepage    = https://github.com/oar-team/colmet;
    platforms   = platforms.unix;
    licence     = licenses.gpl2;
    longDescription = ''
    '';
  };
}
