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
    # Use commit that fixes tests after pygments 2.6.1 -> 2.7.2 upgrade
    rev = "e022398f86efd15d2f04de8bf954364a2b6395b7";
    sha256 = "0kk9f8kfwm53hfc9a5q56ys0v2a5f0nsy7x8kb4vr7vj8fcp5qfa";
  };

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
