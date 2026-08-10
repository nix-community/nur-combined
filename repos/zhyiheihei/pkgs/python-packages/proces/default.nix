{
  lib,
  sources,
  buildPythonPackage,
  setuptools,
}:
buildPythonPackage rec {
  pname = "proces";
  inherit (sources.proces) version src;
  format = "setuptools";

  build-system = [ setuptools ];

  env.PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";

  pythonImportsCheck = [ "proces" ];

  meta = {
    description = "Text preprocess utilities";
    homepage = "https://github.com/Ailln/proces";
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
