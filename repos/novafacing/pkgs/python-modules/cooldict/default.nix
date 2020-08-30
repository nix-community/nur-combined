{ buildPythonPackage
, fetchFromGitHub
, lib
}:

buildPythonPackage rec {
  pname = "cooldict";
  version = "unstable-2019-10-29";

  src = fetchFromGitHub {
    owner = "zardus";
    repo = pname;
    rev = "f4eac5d4fbabbec452f45415615f64c6e3d71a35";
    sha256 = "0ww5kbfqmj4m3fbcmp8rx22php7hargykclja7spjbqjs303hxhv";
  };

  # No tests in repo.
  doCheck = false;

  # Verify imports still work.
  pythonImportsCheck = [ "cooldict" ];

  meta = with lib; {
    description = "Some useful dict-like structures";
    homepage = "https://github.com/zardus/cooldict";
    license = licenses.bsd2;
    maintainers = [ maintainers.pamplemousse ];
  };
}

