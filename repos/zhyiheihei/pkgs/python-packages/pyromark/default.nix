{
  lib,
  sources,
  buildPythonPackage,
  rustPlatform,
  typing-extensions,
}:
buildPythonPackage rec {
  pname = "pyromark";
  inherit (sources.pyromark) version src;
  pyproject = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-MHqZvNUHAhNwZ7iippLTNtVP+sSsXk+Nc5eNkoM6SsU=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  dependencies = [ typing-extensions ];

  env.PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";

  pythonImportsCheck = [ "pyromark" ];

  meta = {
    changelog = "https://github.com/monosans/pyromark/releases/tag/v${version}";
    description = "Blazingly fast Markdown parser";
    homepage = "https://github.com/monosans/pyromark";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
  };
}
