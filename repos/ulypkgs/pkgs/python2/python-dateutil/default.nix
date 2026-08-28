{
  stdenv,
  buildPythonPackage,
  fetchPypi,
  six,
  setuptools-scm,
  pytest,
}:
buildPythonPackage (finalAttrs: {
  pname = "python-dateutil";
  version = "2.8.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-c+v+nb8i6DIoba+mBHPkzSOfhZL2mapa2vEAUObhgjw=";
  };

  checkInputs = [ pytest ];
  propagatedBuildInputs = [ six ];
  nativeBuildInputs = [ setuptools-scm ];

  checkPhase = ''
    py.test dateutil/test
  '';

  # Requires fixing
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Powerful extensions to the standard datetime module";
    homepage = "https://pypi.python.org/pypi/python-dateutil";
    license = "BSD-style";
  };
})
