{ lib, fetchFromGitHub, ocamlPackages }:

ocamlPackages.buildDunePackage rec {
  pname = "tlstunnel";
  version = "2021-08-06";

  src = fetchFromGitHub {
    owner = "roburio";
    repo = pname;
    rev = "3aef371d7f91f09c8e6ab56d94c227a26c3060d9";
    hash = "sha256-7ik3uHinHojidFvlxeJdsVGwvZ8yfqDfoEcMokUVJEg=";
  };

  useDune2 = true;

  propagatedBuildInputs = with ocamlPackages; [
    asn1-combinators
    cmdliner
    ipaddr
    logs
    mirage-crypto
    rresult
  ];

  meta = with lib; {
    description = "A TLS reverse proxy unikernel";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
  };
}
