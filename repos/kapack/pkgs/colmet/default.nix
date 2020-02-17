{ stdenv, fetchFromGitHub, python37Packages, pkgs }:

python37Packages.buildPythonApplication rec {
  pname = "colmet";
  version = "0.5.4";
  
  src = fetchFromGitHub {
    owner = "oar-team";
    repo = "colmet";
    rev = "56e1d9098dea0df340d7798f4cc6d4ba66c567b0";
    sha256 = "1cz97l84xhz3rzhd5rfa92sc7zx8s3mhq71y0fj2si9j5bmcsm0b";
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
