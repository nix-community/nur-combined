{ lib
, buildPythonPackage
, fetchFromGitHub
, oead
, pyyaml
, sortedcontainers
}:

buildPythonPackage rec {
  pname = "byml";
  version = "2.4.2";

  src = fetchFromGitHub {
    owner = "zeldamods";
    repo = "${pname}-v2";
    rev = "v${version}";
    sha256 = "09m9w364fplhxcs8q2zw4mhmwxii6b7876k2zg3da90rz72a4s4g";
  };

  propagatedBuildInputs = [
    oead
    pyyaml
    sortedcontainers
  ];

  checkPhase = ''
    export PATH=$out/bin:$PATH
    python test.py
  '';

  meta = with lib; {
    description = "Nintendo BYML or BYAML parser, writer and converter";
    homepage = "https://github.com/zeldamods/byml-v2";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ metadark ];
  };
}
