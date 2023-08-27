{ lib
, fetchurl
, buildPythonPackage
, datasette
, fetchFromGitHub
}:

let
  pname = "datasette-render-images";
  version = "0.4";
in
buildPythonPackage {
  inherit pname version;

  format = "setuptools";


  src = fetchFromGitHub {
    owner = "simonw";
    repo = pname;
    rev = version;
    hash = "sha256-hq8FySkT1Zv6PoWFvdjLKWF6Er0dcsVpTz+YsSN70GU=";
  };

  propagatedBuildInputs = [
    datasette
  ];

  doCheck = false;

  pythonImportsCheck = [
    "datasette_render_images"
  ];

  passthru.datasette = datasette;

  meta = with lib; {
    description = "Datasette plugin that renders binary blob images using data-uris ";
    homepage = "https://github.com/simonw/datasette-render-images";
    # license = licenses.asl20;
    maintainers = with maintainers; [ SomeoneSerge ];
  };
}
