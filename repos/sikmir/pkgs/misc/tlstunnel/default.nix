{
  lib,
  fetchFromGitHub,
  ocamlPackages,
}:

ocamlPackages.buildDunePackage rec {
  pname = "tlstunnel";
  version = "0-unstable-2024-01-10";

  src = fetchFromGitHub {
    owner = "robur-coop";
    repo = "tlstunnel";
    rev = "c81e48739342e2f5c8ad5537b3543dfad721fc99";
    hash = "sha256-+Cj6eea5IuOZUhCD4zCYddG/AjV/i7jluEeLfhWh5Go=";
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

  meta = {
    description = "A TLS reverse proxy unikernel";
    homepage = "https://github.com/robur-coop/tlstunnel";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    broken = true;
  };
}
