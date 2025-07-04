{ lib, python3Packages, fetchurl }:

python3Packages.buildPythonPackage rec {
  pname = "slices-bi-client";
  version = "3.3.2";
  format = "pyproject";
  src = fetchurl {
    url = "https://doc.slices-ri.eu/pypi/packages/slices_bi_client-${version}.tar.gz";
    hash = "sha256-9uFRMvpEiiA8T/JgUWBzwqqFBU1h9QYGYdMh90H20Xg=";
  };

  buildInputs = with python3Packages; [
    hatchling
    hatch-vcs
  ];

  propagatedBuildInputs = with python3Packages; [
    httpx
    httpx-oauth
    msgspec[toml]
    pyjwt
    tomlkit
    authlib
    pytz
  ];
}
