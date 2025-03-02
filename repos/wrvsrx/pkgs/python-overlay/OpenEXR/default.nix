{
  buildPythonPackage,
  openexr,
  typeguard,
  packaging,
  source,
}:

buildPythonPackage {
  inherit (source) pname version src;
  doCheck = false;
  patches = [ ./openexr.patch ];
  buildInputs = [ openexr ];
  propagatedBuildInputs = [
    typeguard
    packaging
  ];
}
