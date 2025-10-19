{
  lib,
  stdenv,
  pins,
  libyaml,
  yajl,
}:

stdenv.mkDerivation rec {
  pname = "json-yaml";
  version = "1.2.1";

  src = pins.json-yaml.outPath;

  buildInputs = [
    libyaml
    yajl
  ];

  installFlags = [
    "PREFIX=$(out)"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Converts JSON to YAML and back";
    homepage = "https://github.com/sjmulder/json-yaml";
    maintainers = with maintainers; [ arobyn ];
    license = licenses.bsd2;
  };
}
