{ lib, python3Packages, fetchurl, fetchgit, fetchFromGitHub, dockerTools }:

python3Packages.buildPythonApplication rec {
  pname = "ww-manager"; # 根据 pyproject.toml 的 name 修正
  version = "2.1.12";   # 锁定到具体的版本号

  src = fetchFromGitHub {
    owner = "timetetng";
    repo = "wutheringwaves-cli-manager";
    rev = "v${version}"; 
    hash = "sha256-1BYcPAzsFVUHXHqPKOLrQwTEJcX4OIxAkJDMN3BNS3M="; 
  };

  # 在解压源码后、构建开始前执行的补丁阶段
  postPatch = ''
    # 放宽对 typing-extensions 的版本限制，将其替换为无版本限制
    sed -i 's/typing-extensions>=4.15.0/typing-extensions/g' pyproject.toml
  '';

  # 明确使用 pyproject 构建格式
  format = "pyproject";

  # 构建时依赖：pyproject.toml 中 [build-system] 指定的后端
  nativeBuildInputs = with python3Packages; [
    hatchling
  ];

  # 运行时依赖：pyproject.toml 中 dependencies 列出的库
  propagatedBuildInputs = with python3Packages; [
    typer
    certifi
    rich
    typing-extensions
    requests
  ];

  # 禁用测试以加快构建速度（如果项目中包含 pytest 等测试，且你想跑的话可以改为 true）
  doCheck = false;

  meta = with lib; {
    description = "鸣潮命令行管理器";
    homepage = "https://github.com/timetetng/wutheringwaves-cli-manager";
    license = licenses.mit; # 许可证类型需根据原仓库实际情况确认
    mainProgram = "ww";     # 根据 [project.scripts] 提取出的实际启动命令
    platforms = platforms.linux;
  };
}
