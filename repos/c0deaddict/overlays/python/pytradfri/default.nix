{ stdenv, fetchFromGitHub, buildPythonPackage
, pytest, aiocoap, dtlssocket }:

buildPythonPackage rec {
  pname = "pytradfri";
  version = "6.4.0";

  src = fetchFromGitHub {
    owner = "ggravlingen";
    repo = "pytradfri";
    rev = version;
    sha256 = "1lk8nwi1wpdvlklrjhj0629hz0ihp97cqirmgnsnvgw94r4anw82";
  };

  propagatedBuildInputs = [ aiocoap dtlssocket ];
  checkInputs = [ pytest ];

  checkPhase = ''
    pytest
  '';

  meta = with stdenv.lib; {
    description = "IKEA Trådfri/Tradfri API. Control and observe your lights from Python.";
    homepage = "https://github.com/ggravlingen/pytradfri";
    license = licenses.mit;
  };
}
