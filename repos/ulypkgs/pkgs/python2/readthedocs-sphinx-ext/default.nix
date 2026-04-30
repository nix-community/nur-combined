{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
  pytestCheckHook,
  mock,
  sphinx,
}:

buildPythonPackage rec {
  pname = "readthedocs-sphinx-ext";
  version = "2.2.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-7l/VuZ258MGAsjlsvOUoqjZnGVG5UmuwJy2/zlUXvSc=";
  };

  propagatedBuildInputs = [ requests ];

  checkInputs = [
    mock
    sphinx
  ];
  nativeCheckInputs = [ pytestCheckHook ];

  meta = with lib; {
    description = "Sphinx extension for Read the Docs overrides";
    homepage = "https://github.com/rtfd/readthedocs-sphinx-ext";
    license = licenses.mit;
  };
}
