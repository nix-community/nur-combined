{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "hhsh";
  version = "0.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "yihong0618";
    repo = "nbnhhsh-cli";
    rev = "main";
    hash = "sha256-Dw6DouP9sjmaUzpePUX6MDQ3E/2wAFe+AeB4x/qBbOY=";
  };

  build-system = [ python3.pkgs.setuptools ];

  propagatedBuildInputs = with python3.pkgs; [
    requests
    rich
  ];

  meta = with lib; {
    description = "「能不能好好说话？」 cli 版本 - 拼音首字母缩写翻译工具";
    homepage = "https://github.com/yihong0618/nbnhhsh-cli";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.all;
    mainProgram = "hhsh";
  };
}
