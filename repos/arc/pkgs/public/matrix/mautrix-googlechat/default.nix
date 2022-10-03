{ fetchFromGitHub, fetchpatch
, lib
, python3Packages
, protobuf3_19 ? protobuf
, protobuf
, e2be ? true, metrics ? false
}: with python3Packages; let

  mautrix = python3Packages.mautrix.overridePythonAttrs (old: rec {
    version = "0.18.1";
    src = old.src.override {
      inherit version;
      sha256 = "sha256-flHww6jvelE4fYkQzPFylMPGR6W4x0THkKwz8bVGE5Y=";
    };
  });

in buildPythonApplication rec {
  pname = "mautrix-googlechat";
  version = "2022-09-15";

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "googlechat";
    rev = "bf2724cbc85c4ae56a17d805753f2a52ba0b0865";
    sha256 = "sha256-ZPHB4DSoGGGyDhX80qpKT/7zfpYWOl6d5WhWmYMvV+Q=";
  };

  patches = [ ./entrypoint.patch ];

  postPatch = ''
    sed -i -e 's/asyncpg>=.*/asyncpg/' requirements.txt
  '';

  propagatedBuildInputs = [
    aiohttp
    yarl
    asyncpg
    ruamel_yaml
    CommonMark
    python_magic
    (python3Packages.protobuf.override {
      protobuf = protobuf3_19;
    })
    mautrix
    setuptools
  ] ++ lib.optionals e2be [
    python-olm
    pycryptodome
    unpaddedbase64
  ] ++ lib.optionals metrics [
    prometheus_client
  ];

  meta.broken = lib.versionOlder mautrix.version "0.16.6";
  passthru = {
    pythonModule = python;
    pythonPackage = "mautrix_googlechat";
  };

  doCheck = false;
}
