{ lib
, python3
, fetchPypi
}:

python3.pkgs.buildPythonPackage rec {
  pname = "mkdocs-include-markdown-plugin";
  version = "6.0.4";
  format = "wheel";

  src = fetchPypi rec {
    inherit version format;
    pname = "mkdocs_include_markdown_plugin";
    hash = "sha256-57i17MQdaj4Wlpz/NyXsOjkbaOnf4aS042qFCL7NqDU=";
    dist = python;
    python = "py3";
  };

  propagatedBuildInputs = [ python3.pkgs.wcmatch ];

  meta = with lib; {
    description = "Mkdocs Markdown includer plugin";
    homepage = "https://github.com/mondeja/mkdocs-include-markdown-plugin";
    license = licenses.asl20;
    maintainers = with maintainers; [ caarlos0 ];
    changelog = "https://github.com/mondeja/mkdocs-include-markdown-plugin/releases/tag/v${version}";
  };
}
