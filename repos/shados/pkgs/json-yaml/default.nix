{ stdenv, fetchFromGitHub
, libyaml, yajl
}:

stdenv.mkDerivation rec {
  pname = "json-yaml";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "sjmulder"; repo = pname;
    rev = version;
    sha256 = "1g2fh1nl3xr8lfvzm6infqj8cxavjrggnn790sqgc4mzq52nqk48";
  };

  buildInputs = [
    libyaml yajl
  ];

  installFlags = [
    "PREFIX=$(out)"
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Converts JSON to YAML and back";
    homepage    = "https://github.com/sjmulder/json-yaml";
    maintainers = with maintainers; [ arobyn ];
    license     = licenses.bsd2;
  };
}
