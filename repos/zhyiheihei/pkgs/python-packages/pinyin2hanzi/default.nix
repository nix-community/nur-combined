{
  lib,
  sources,
  buildPythonPackage,
  setuptools,
}:
buildPythonPackage rec {
  pname = "Pinyin2Hanzi";
  inherit (sources.pinyin2hanzi) version src;
  format = "setuptools";

  build-system = [ setuptools ];

  env.PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";

  pythonImportsCheck = [ "Pinyin2Hanzi" ];

  meta = {
    description = "Pinyin to Chinese character conversion engine";
    homepage = "https://github.com/someus/Pinyin2Hanzi";
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
