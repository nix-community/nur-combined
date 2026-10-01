{ lib
, python3
, sources
}:

python3.pkgs.buildPythonApplication rec {
  pname = "hhsh";
  # Upstream publishes neither tags nor releases; nvfetcher tracks the branch
  # tip and exposes its UTC commit date.
  version = "0-unstable-${sources.hhsh.date}";

  pyproject = true;

  src = sources.hhsh.src;

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
