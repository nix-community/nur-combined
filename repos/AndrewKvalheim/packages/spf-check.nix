{ fetchFromGitHub
, lib
, stdenv
, unstableGitUpdater

  # Dependencies
, python3
}:

stdenv.mkDerivation {
  pname = "spf-check";
  version = "0-unstable-2023-11-20";

  src = fetchFromGitHub {
    owner = "gsvitins";
    repo = "spf-dns-lookup-check";
    rev = "3a2496ccf1d046f6c1cc4a1a8cc501e13a60a9dc";
    hash = "sha256-cXjiiOQjrRUckO9GhHa7INyIBSM4eU+EpowJRT9is0o=";
  };

  buildInputs = [ (python3.withPackages (p: with p; [ dnspython ])) ];

  doCheck = true;
  checkPhase = "python3 spf-check.py --help > /dev/null";

  postInstall = ''
    install -D spf-check.py $out/bin/spf-check
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Recursively check DNS lookups in SPF record";
    homepage = "https://github.com/gsvitins/spf-dns-lookup-check";
    license = lib.licenses.unlicense;
  };
}
