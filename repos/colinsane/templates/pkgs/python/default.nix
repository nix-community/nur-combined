{
  lib,
  fetchFromGitHub,
  # pypaBuildHook,
  # pypaInstallHook,
  pytestCheckHook,
  stdenv,
}: stdenv.mkDerivation (finalAttrs: {
  # pname = "mypackage";
  # version = "0.1-unstable-2024-06-04";

  src = fetchFromGitHub {
    # owner = "owner";
    # repo = "repo";
    rev = "v${finalAttrs.version}";
    # hash = "";
  };

  nativeBuildInputs = [
    # poetry-core
    # pypaBuildHook
    # pypaInstallHook
  ];

  propagatedBuildInputs = [
    # other python modules this depends on, if this package is supposed to be importable
  ];

  nativeCheckInputs = [
    # pytestCheckHook
  ];

  pythonImportsCheck = [
    # "mymodule"
  ];

  meta = with lib; {
    # homepage = "https://example.com";
    # description = "python template project";
    maintainers = with maintainers; [ colinsane ];
  };
})
