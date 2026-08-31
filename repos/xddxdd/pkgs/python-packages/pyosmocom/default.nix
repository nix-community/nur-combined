{
  fetchgit,
  lib,
  buildPythonPackage,
  # Dependencies
  unstableGitUpdater,
  setuptools,
  construct,
  gsm0338,
}:
buildPythonPackage (finalAttrs: {
  pname = "pyosmocom";
  version = "0.0.12-unstable-2026-08-23";
  pyproject = true;

  src = fetchgit {
    url = "https://gitea.osmocom.org/osmocom/pyosmocom.git";
    rev = "e1701b243335277b5214619e3edbbcb7099ccecf";
    fetchSubmodules = false;
    hash = "sha256-/QPEadNkCYvjXFW1DB5vKvxlxx6KTv2sYqJ09NhCY8Y=";
  };
  build-system = [ setuptools ];
  dependencies = [
    construct
    gsm0338
  ];

  pythonImportsCheck = [ "osmocom" ];

  passthru.updateScript = unstableGitUpdater {
    url = "https://gitea.osmocom.org/osmocom/pyosmocom.git";
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Python implementation of key Osmocom protocols/interfaces";
    homepage = "https://gitea.osmocom.org/osmocom/pyosmocom";
    license = with lib.licenses; [ gpl2Only ];
  };
})
