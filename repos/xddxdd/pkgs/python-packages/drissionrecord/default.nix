{
  fetchurl,
  lib,
  buildPythonPackage,
  # Dependencies
  nix-update-script,
  openpyxl,
  setuptools,
}:
buildPythonPackage rec {
  pname = "drissionrecord";
  version = "2.0.1";
  pyproject = true;

  src = fetchurl {
    url = "mirror://pypi/d/drissionrecord/drissionrecord-${version}";
    hash = "sha256-hjMFvAmuxYFYBF9F62k14VuprBXjWJIBBbIPSnMLLtc=";
  };
  build-system = [ setuptools ];
  dependencies = [ openpyxl ];

  pythonImportsCheck = [ "DrissionRecord" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Python data recording toolkit";
    homepage = "https://gitcode.com/g1879/DrissionRecord";
    license = with lib.licenses; [ mit ];
  };
}
