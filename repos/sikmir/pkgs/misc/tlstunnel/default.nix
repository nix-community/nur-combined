{ lib, fetchFromGitHub, ocamlPackages }:

ocamlPackages.buildDunePackage rec {
  pname = "tlstunnel";
  version = "2023-03-09";

  src = fetchFromGitHub {
    owner = "roburio";
    repo = "tlstunnel";
    rev = "85413a3c2c54fdeda982fdca5d6035e6b740f6fe";
    hash = "sha256-Oe4sDLFoTUzb65LDUcdqyRHAq13ap4Gme+GA3fPpHmc=";
  };

  sourceRoot = "${src.name}/client";

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
