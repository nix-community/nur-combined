{
  lib,
  fetchFromGitHub,
  fetchpatch,
  python3Packages,
  pytest-skip-markers,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pytest-shell-utilities";
  version = "1.9.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "saltstack";
    repo = "pytest-shell-utilities";
    tag = finalAttrs.version;
    hash = "sha256-1xHTaYurVusWXVjVwiiUdeC1SN02U3E6p1hOYp78Msw=";
  };

  patches = [
    # Support pytest 9
    (fetchpatch {
      url = "https://github.com/saltstack/pytest-shell-utilities/commit/b6f26e62a20fc8c42635a2b868e8915cc2a0b21d.patch";
      hash = "sha256-QKk3EnJRMiuaZRHi/qkpJBsOBOuHROMSXb9fN36ZNzo=";
    })
  ];

  SETUPTOOLS_SCM_PRETEND_VERSION = finalAttrs.version;

  build-system = with python3Packages; [
    setuptools-scm
    setuptools-declarative-requirements
  ];

  dependencies = with python3Packages; [
    psutil
    pytest-skip-markers
    pytest-helpers-namespace
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  __darwinAllowLocalNetworking = true;

  meta = {
    description = "Pytest Shell Utilities";
    homepage = "https://github.com/saltstack/pytest-shell-utilities";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
