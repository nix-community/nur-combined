{
  lib,
  python3Packages,
  fetchFromGitHub,
  makeWrapper,
  nix-update-script,
  playwright-driver,
}:

python3Packages.buildPythonApplication rec {
  pname = "quarkpantool";
  version = "0.0.6";
  format = "other";

  src = fetchFromGitHub {
    owner = "ihmily";
    repo = "QuarkPanTool";
    rev = "v${version}";
    hash = "sha256-oW1mYtOjDZo8cBfE0jRYEjRrwxQwJupCD50pJaA16B0=";
  };

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = with python3Packages; [
    httpx
    retrying
    prettytable
    playwright
    tqdm
    colorama
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/quarkpantool
    cp -r *.py config $out/lib/quarkpantool/

    mkdir -p $out/bin
    makeWrapper ${python3Packages.python.interpreter} $out/bin/quarkpantool \
      --add-flags "$out/lib/quarkpantool/quark.py" \
      --prefix PYTHONPATH : "${python3Packages.makePythonPath propagatedBuildInputs}" \
      --set PLAYWRIGHT_BROWSERS_PATH "${playwright-driver.browsers}"

    makeWrapper ${python3Packages.python.interpreter} $out/bin/quarkpantool-login \
      --add-flags "$out/lib/quarkpantool/quark_login.py" \
      --prefix PYTHONPATH : "${python3Packages.makePythonPath propagatedBuildInputs}" \
      --set PLAYWRIGHT_BROWSERS_PATH "${playwright-driver.browsers}"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "一个批量转存、分享和下载夸克网盘文件的命令行工具";
    homepage = "https://github.com/ihmily/QuarkPanTool";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "quarkpantool";
  };
}
