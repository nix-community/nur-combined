{ lib
, buildPythonPackage
, python
, fetchFromGitHub
, poetry-core
, teslajsonpy
}:

buildPythonPackage rec {
  pname = "tesla-custom-component";
  version = "1.2.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "alandtse";
    repo = "tesla";
    rev = "v${version}";
    sha256 = "0dy4gsb80v221qsxadmkzrdcclxzs5469p2pclwdmwq2r0012h6h";
  };

  patches = [ ./poetry.patch ];

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    teslajsonpy
  ];

  meta = with lib; {
    homepage = "https://github.com/alandtse/tesla";
    license = licenses.asl20;
    description = "A fork of the official Tesla integration in Home Assistant to use an oauth proxy for logins.";
    maintainers = with maintainers; [ graham33 ];
  };
}
