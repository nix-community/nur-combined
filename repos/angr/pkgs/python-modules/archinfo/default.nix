{ buildPythonPackage
, fetchFromGitHub
, isPy3k
, nose
, pkgs
}:

buildPythonPackage rec {
  pname = "archinfo";
  version = "8.20.1.7";
  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "angr";
    repo = pname;
    rev = "fa979436bd07b4178877d31a5166d28063a89807";
    sha256 = "018asj1gnnc189i7gnd3gm7as58pd6r6lpfd7aq57848rlrsrxv8";
  };

  checkInputs = [ nose ];
  checkPhase = ''
    nosetests tests/
  '';

  meta = with pkgs.lib; {
    description = "A collection of classes that contain architecture-specific information";
    homepage = "https://github.com/angr/archinfo";
    license = licenses.bsd2;
    maintainers = [ maintainers.pamplemousse ];
  };
}
