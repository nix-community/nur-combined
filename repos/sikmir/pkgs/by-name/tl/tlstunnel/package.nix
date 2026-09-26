{
  lib,
  fetchFromGitHub,
  ocamlPackages,
  writableTmpDirAsHomeHook,
}:

ocamlPackages.buildDunePackage rec {
  pname = "tlstunnel";
  version = "0-unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "robur-coop";
    repo = "tlstunnel";
    rev = "4d9a1eafdc1f67644c20e022f755fdbf41fb950b";
    hash = "sha256-VpTfeiAQF4oUdakna3cdXzdQMMtf2CVFhSU3IRxx4rk=";
  };

  sourceRoot = "${src.name}/client";

  useDune2 = true;

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];

  propagatedBuildInputs = with ocamlPackages; [
    asn1-combinators
    cmdliner
    fmt
    ipaddr
    logs
    digestif
  ];

  meta = {
    description = "A TLS reverse proxy unikernel";
    homepage = "https://github.com/robur-coop/tlstunnel";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
