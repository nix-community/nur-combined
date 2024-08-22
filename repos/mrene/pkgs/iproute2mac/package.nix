{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "iproute2mac";
  version = "1.5.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "brona";
    repo = "iproute2mac";
    rev = "v${version}";
    hash = "sha256-YtUTm/f0deLpSZzNrAnNfvhx46lae1V36EAY3l1aBQg=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [ "iproute2mac" ];

  postInstall = ''
    mkdir -p $out/bin
    chmod +x $out/${python3.sitePackages}/ip.py
    chmod +x $out/${python3.sitePackages}/bridge.py
    cp -s $out/${python3.sitePackages}/ip.py $out/bin/ip
    cp -s $out/${python3.sitePackages}/bridge.py $out/bin/bridge
  '';

  meta = with lib; {
    description = "CLI wrapper for basic network utilites on Mac OS X inspired with iproute2 on Linux systems - ip command";
    homepage = "https://github.com/brona/iproute2mac";
    license = licenses.mit;
    maintainers = with maintainers; [ mrene ];
    mainProgram = "iproute2mac";
    platforms = platforms.darwin;
  };
}
