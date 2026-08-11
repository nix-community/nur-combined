{
  lib,
  sources,
  buildPythonPackage,
  setuptools,
}:
buildPythonPackage rec {
  pname = "torrentool";
  inherit (sources.torrentool) version src;
  format = "setuptools";

  build-system = [ setuptools ];

  doCheck = false;

  env.PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";

  pythonImportsCheck = [ "torrentool" ];

  meta = {
    description = "Tool to work with torrent files";
    homepage = "https://github.com/idlesign/torrentool";
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
