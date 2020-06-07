{ buildPythonPackage
, fetchFromGitHub
, isPy3k
, nose
, nose2
, pkgs
}:

buildPythonPackage rec {
  pname = "archinfo";
  version = "8.20.6.1";
  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "angr";
    repo = pname;
    rev = "ad017e5d782c6a7d23bfdbec4c7d73d6899565d5";
    sha256 = "1nsm1vhc8pk8kxdq0p0sgd19sgg0p8zfk6pcq0czds9i1hdhgca4";
  };

  checkInputs = [ nose nose2 ];
  checkPhase = ''
    nose2 -s tests/
  '';

  meta = with pkgs.lib; {
    description = "A collection of classes that contain architecture-specific information";
    homepage = "https://github.com/angr/archinfo";
    license = licenses.bsd2;
    maintainers = [ maintainers.pamplemousse ];
  };
}
