{ fetchFromGitHub, fetchpatch
, lib
, python3Packages
, protobuf3_19 ? protobuf
, protobuf
, e2be ? true, metrics ? false
}: with python3Packages; let

  mautrix = python3Packages.mautrix.overridePythonAttrs (old: rec {
    version = "0.18.6";
    src = old.src.override {
      inherit version;
      sha256 = "sha256-IpFtdDCGSM6A6l0/IYkfTgV+fLlco340Tos4msx9XEs=";
    };
  });

in buildPythonApplication rec {
  pname = "mautrix-googlechat";
  version = "2022-10-20";

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "googlechat";
    rev = "98cd8c31422adad0bd8242c54c2701d58a34a629";
    sha256 = "sha256-QMQBgZEhY4xw8bu83KtEm1ReHzSVT6Y9GL5qsHJXqcg=";
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

  meta.broken = lib.versionOlder mautrix.version "0.18.5";
  passthru = {
    pythonModule = python;
    pythonPackage = "mautrix_googlechat";
  };

  doCheck = false;
}
