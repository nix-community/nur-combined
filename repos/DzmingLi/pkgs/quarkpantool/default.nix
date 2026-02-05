{
  lib,
  python3Packages,
  fetchFromGitHub,
  makeWrapper,
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
      --set PLAYWRIGHT_BROWSERS_PATH "${playwright-driver.browsers}"

    makeWrapper ${python3Packages.python.interpreter} $out/bin/quarkpantool-login \
      --add-flags "$out/lib/quarkpantool/quark_login.py" \
      --set PLAYWRIGHT_BROWSERS_PATH "${playwright-driver.browsers}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "A command-line tool for managing Quark cloud storage";
    longDescription = ''
      QuarkPanTool is a utility for Quark cloud storage that enables:
      - Batch transfer of shared files to personal storage
      - Batch generation of share links
      - Batch downloading of files
      - Web-based authentication using Playwright
    '';
    homepage = "https://github.com/ihmily/QuarkPanTool";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "quarkpantool";
  };
}
