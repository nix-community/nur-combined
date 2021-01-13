{ buildPythonPackage
, fetchFromGitHub
, isPy3k
, nose
, nose2
, pkgs
}:

buildPythonPackage rec {
  pname = "archinfo";
  version = "9.0.5405";
  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "angr";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-RKtgw9MAgVZoC7bicSnVa2N3JEZaNDdFrzJNWe4QQQg=";
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
