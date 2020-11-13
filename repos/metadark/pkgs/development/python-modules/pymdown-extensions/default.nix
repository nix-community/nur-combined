{ lib
, buildPythonPackage
, fetchFromGitHub
, markdown
, pygments
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

  patches = [
    # Reverts https://github.com/facelessuser/pymdown-extensions/pull/1103
    # This fix was for Pygments 2.7, but we still use pygments 2.6.1
    ./fix-tests.patch
  ];

  propagatedBuildInputs = [ markdown ];

  checkInputs = [
    pygments
    pytestCheckHook
    pyyaml
  ];

  meta = with lib; {
    description = "Extensions for Python Markdown";
    homepage = "https://github.com/facelessuser/pymdown-extensions";
    license = licenses.mit;
    maintainers = with maintainers; [ metadark ];
  };
}
