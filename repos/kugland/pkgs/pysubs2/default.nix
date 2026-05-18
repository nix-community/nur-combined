{ lib
, python3Packages
,
}:
python3Packages.buildPythonPackage rec {
  pname = "pysubs2";
  version = "1.8.1";
  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-rzoohkPah9trsT295w6UyVcHZcyPZCOxwh3hHxbXNNo=";
  };
  pyproject = true;
  build-system = with python3Packages; [ hatchling ];
  meta = with lib; {
    description = "A Python library for editing subtitle files";
    homepage = "https://github.com/tkarabela/pysubs2";
    license = licenses.mit;
    maintainers = with maintainers; [ kugland ];
  };
}
