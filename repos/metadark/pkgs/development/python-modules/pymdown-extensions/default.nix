{ lib
, buildPythonPackage
, fetchFromGitHub
, markdown
, pytestCheckHook
, pyyaml
}:

buildPythonPackage rec {
  pname = "pymdown-extensions";
  version = "8.0.1";

  src = fetchFromGitHub {
    owner = "facelessuser";
    repo = pname;
    rev = version;
    sha256 = "1j14r9r1zxf6c58phimlygcjzbqxk53axdfpak398ghxl4ch4nmv";
  };

  propagatedBuildInputs = [ markdown ];

  doCheck = false; # A bunch of tests fail right now :(
  checkInputs = [ pytestCheckHook pyyaml ];

  meta = with lib; {
    description = "Extensions for Python Markdown";
    homepage = "https://github.com/facelessuser/pymdown-extensions";
    license = licenses.mit;
    maintainers = with maintainers; [ metadark ];
  };
}
