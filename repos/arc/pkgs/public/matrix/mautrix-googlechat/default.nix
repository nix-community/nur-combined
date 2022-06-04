{ fetchFromGitHub, fetchpatch, lib, python3Packages, e2be ? true, metrics ? false }: with python3Packages; let

  mautrix = python3Packages.mautrix.overridePythonAttrs (old: rec {
    version = "0.15.0";
    src = old.src.override {
      inherit version;
      sha256 = "00h6r5znb8hbjr69ihx8qxvbj9fls2723k82dnaky6yq2g42v9d7";
    };
  });

in buildPythonApplication rec {
  pname = "mautrix-googlechat";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "googlechat";
    rev = "v${version}";
    sha256 = "1wwmj2wcyzw89q34vbya20idwy13wpiinl2wr7f0bbwqp0xicjak";
  };

  patches = [ ./entrypoint.patch ];

  propagatedBuildInputs = [
    aiohttp
    yarl
    asyncpg
    ruamel_yaml
    CommonMark
    python_magic
    protobuf
    mautrix
    setuptools
  ] ++ lib.optionals e2be [
    python-olm
    pycryptodome
    unpaddedbase64
  ] ++ lib.optionals metrics [
    prometheus_client
  ];

  meta.broken = lib.versionOlder mautrix.version "0.14.6";
  passthru = {
    pythonModule = python;
    pythonPackage = "mautrix_googlechat";
  };

  doCheck = false;
}
