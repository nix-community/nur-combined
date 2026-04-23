{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  poetry-core,
  cryptography,
  tenacity,
}:

buildPythonPackage (finalAttrs: {
  pname = "aia-chaser";
  version = "3.4.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jponf";
    repo = "aia-chaser";
    # tag = finalAttrs.version;
    # https://github.com/jponf/aia-chaser/pull/13
    rev = "3bac5263891949e43c32bb8ebe09c2aba521283e";
    hash = "sha256-A6G/TIdWXLHwrQC3WqISr5q1a+xEuLsBWRKkg5q5VDQ=";
  };

  build-system = [
    poetry-core
  ];

  dependencies = [
    cryptography
    tenacity
  ];

  pythonImportsCheck = [
    "aia_chaser"
  ];

  meta = {
    description = "Chase authority information access (AIA) from a host certificate to complete the chain of trust";
    homepage = "https://github.com/jponf/aia-chaser";
    changelog = "https://github.com/jponf/aia-chaser/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
})
