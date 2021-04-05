{ buildPythonPackage
, fetchFromGitHub
, isPy3k
, nose
, nose2
, pkgs
}:

buildPythonPackage rec {
  pname = "archinfo";
  version = "9.0.6588";
  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "angr";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-MWs/Pt0WH4j+ABWjVdEIMxpYu1O7o/Dn1uWgrVYEq/k=";
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
