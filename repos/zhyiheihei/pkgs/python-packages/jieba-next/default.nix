{
  lib,
  sources,
  buildPythonPackage,
  rustPlatform,
  cargo,
  rustc,
  setuptools,
  setuptools-rust,
  setuptools-scm,
}:
buildPythonPackage rec {
  pname = "jieba-next";
  inherit (sources."jieba-next") version src;
  pyproject = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-xx8QLY3DCFmrZwPVZ2pcSsYnf/MdI9MQhFjskUAu24U=";
  };

  nativeBuildInputs = [
    cargo
    rustc
    rustPlatform.cargoSetupHook
  ];

  build-system = [
    setuptools
    setuptools-rust
    setuptools-scm
  ];

  env.SETUPTOOLS_SCM_PRETEND_VERSION = version;
  env.PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";

  pythonImportsCheck = [ "jieba_next" ];

  meta = {
    description = "Modern jieba fork with Rust speedups";
    homepage = "https://github.com/mxcoras/jieba-next";
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
