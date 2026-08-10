{
  lib,
  sources,
  buildPythonPackage,
  setuptools,
  proces,
}:
buildPythonPackage rec {
  pname = "cn2an";
  inherit (sources.cn2an) version src;
  format = "setuptools";

  build-system = [ setuptools ];

  dependencies = [ proces ];

  env.PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";

  pythonImportsCheck = [ "cn2an" ];

  meta = {
    description = "Convert Chinese numerals and Arabic numerals";
    homepage = "https://github.com/Ailln/cn2an";
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
