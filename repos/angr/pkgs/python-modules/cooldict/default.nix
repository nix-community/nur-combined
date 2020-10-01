{ buildPythonPackage
, fetchFromGitHub
, lib
}:

buildPythonPackage rec {
  pname = "cooldict";
  version = "unstable-2019-10-30";

  src = fetchFromGitHub {
    owner = "zardus";
    repo = pname;
    rev = "f4eac5d4fbabbec452f45415615f64c6e3d71a35";
    sha256 = "sha256-G3Y4wNASL3n1UZKy6V9W8Fx4hegZ3cqWG5XIit2ahXM=";
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

