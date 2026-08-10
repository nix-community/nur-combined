{
  lib,
  sources,
  buildPythonPackage,
  setuptools,
  setuptools-scm,
}:
buildPythonPackage rec {
  pname = "aioshutil";
  inherit (sources.aioshutil) version src;
  format = "setuptools";

  build-system = [
    setuptools
    setuptools-scm
  ];

  env.SETUPTOOLS_SCM_PRETEND_VERSION = version;
  env.PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";

  pythonImportsCheck = [ "aioshutil" ];

  meta = {
    description = "Asynchronous shutil module";
    homepage = "https://github.com/kumaraditya303/aioshutil";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
  };
}
