{
  lib,
  sources,
  buildPythonPackage,
  pdm-backend,
  pyromark,
}:
buildPythonPackage rec {
  pname = "telegramify-markdown";
  version = lib.removePrefix "pypi_" sources."telegramify-markdown".version;
  inherit (sources."telegramify-markdown") src;
  pyproject = true;

  build-system = [ pdm-backend ];

  dependencies = [ pyromark ];

  env.PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";

  pythonImportsCheck = [ "telegramify_markdown" ];

  meta = {
    changelog = "https://github.com/sudoskys/telegramify-markdown/releases/tag/${version}";
    description = "Convert Markdown to Telegram plain text and entities";
    homepage = "https://github.com/sudoskys/telegramify-markdown";
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
