{
  stdenv,
  lib,
  buildPythonPackage,
  fetchPypi,
  pytz,
  pytestCheckHook,
  freezegun,
}:

buildPythonPackage (finalAttrs: {
  pname = "Babel";
  version = "2.9.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-vAwXb59qmUWCIw3zUKpuBbouvks6wxfqsp2b5dJ2jaA=";
  };

  propagatedBuildInputs = [ pytz ];

  checkInputs = [
    pytestCheckHook
    freezegun
  ];

  doCheck = !stdenv.isDarwin;

  meta = with lib; {
    homepage = "http://babel.edgewall.org";
    description = "A collection of tools for internationalizing Python applications";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
  };
})
