{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  aio-udp-server,
  cerberus,
  py3-bencode,
}:

buildPythonPackage (finalAttrs: {
  pname = "aio-krpc-server";
  version = "0.0.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "bashkirtsevich-llc";
    repo = "aiokrpc";
    rev = "fe0b18a98d4dc19034f8152afbae78fb600830e2";
    hash = "sha256-RfG3csVihigXTJRa6X8o1BhlUEgFWfmZTm6zcD2K2ik=";
  };

  postPatch = ''
    sed -i -E 's/==[0-9.]+"/"/' setup.py
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    aio-udp-server
    cerberus
    py3-bencode
  ];

  pythonImportsCheck = [
    "aiokrpc"
  ];

  meta = {
    description = "Asyncio KRPC-server";
    homepage = "https://github.com/bashkirtsevich-llc/aiokrpc";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
  };
})
