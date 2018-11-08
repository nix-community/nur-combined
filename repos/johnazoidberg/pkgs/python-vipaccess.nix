{ stdenv, lib, fetchFromGitHub, python36Packages
, lxml, pycryptodome, requests, oath }:
python36Packages.buildPythonApplication rec {
  name = "python-vipaccess-${version}";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "dlenski";
    repo = "python-vipaccess";
    rev = "v${version}";
    sha256 = "1gi97ni91hp2yvknhap9bjn59glw6pxzdfyya2zf81naymy47xr1";
  };

  doCheck = false;

  propagatedBuildInputs = with python36Packages; [
    lxml pycryptodome requests oath
  ];

  meta = with stdenv.lib; {
    description = "Free software implementation of Symantec's VIP Access application and protocol";
    license = licenses.asl20;
    homepage = https://github.com/dlenski/python-vipaccess;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}
