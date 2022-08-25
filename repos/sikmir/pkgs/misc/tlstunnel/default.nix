{ lib, fetchFromGitHub, ocamlPackages }:

ocamlPackages.buildDunePackage rec {
  pname = "tlstunnel";
  version = "2022-01-09";

  src = fetchFromGitHub {
    owner = "roburio";
    repo = "tlstunnel";
    rev = "4f70374a22ea6e7913e420f85246308186eed9c8";
    hash = "sha256-pY3z95jU5WPqaAIdGab9JcYgKxcPLAmjlZlPZ23F2Bk=";
  };

  useDune2 = true;

  propagatedBuildInputs = with ocamlPackages; [
    asn1-combinators
    cmdliner
    fmt
    ipaddr
    logs
    mirage-crypto
  ];

  meta = with lib; {
    description = "A TLS reverse proxy unikernel";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
  };
}
