{ fetchFromGitHub, fetchpatch
, lib
, python3Packages
, protobuf3_19 ? protobuf
, protobuf
, e2be ? true, metrics ? false
}: with python3Packages; buildPythonApplication rec {
  pname = "mautrix-googlechat";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "googlechat";
    rev = "v${version}";
    sha256 = "sha256-UVWYT0HTOUEkBG0n6KNhCSSO/2PAF1rIvCaw478z+q0=";
  };

  patches = [ (fetchpatch {
    url = "https://github.com/mautrix/googlechat/commit/596c20111dbbbb2e07cc344d039081f0eb8bf874.patch";
    sha256 = "sha256-DsITDNLsIgBIqN6sD5JHaFW0LToxVUTzWc7mE2L09IQ=";
  }) ];

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
