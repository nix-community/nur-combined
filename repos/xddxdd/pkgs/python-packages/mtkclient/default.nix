{
  lib,
  sources,
  python3,
  buildPythonPackage,
  keystone,
  # Dependencies
  capstone,
  colorama,
  flake8,
  fusepy,
  keystone-engine,
  mock,
  pycryptodome,
  pycryptodomex,
  pyserial,
  pyside6,
  pyusb,
  setuptools,
  shiboken6,
  unicorn,
}:
buildPythonPackage rec {
  inherit (sources.mtkclient) pname version src;
  pyproject = true;

  buildInputs = [ keystone ];
  propagatedBuildInputs = [
    capstone
    colorama
    flake8
    fusepy
    keystone-engine
    mock
    pycryptodome
    pycryptodomex
    pyserial
    pyside6
    pyusb
    setuptools
    shiboken6
    unicorn
  ];

  postPatch = ''
    sed -i "s#if __name__ == '__main__':#def main():#g" mtk.py mtk_gui.py
    sed -i "s#mtkclient.mtk_gui:main#mtk_gui:main#g" pyproject.toml
  '';

  # Upstream pyproject.toml is badly written and misses a lot of files during installation
  # Instead of fixing pyproject.toml, I'm just copying everything since it's much easier
  postFixup = ''
    cp -r *.py $out/lib/python${python3.pythonVersion}/site-packages/
    cp -r mtkclient $out/lib/python${python3.pythonVersion}/site-packages/
  '';

  pythonImportsCheck = [ "mtkclient" ];

  meta = {
    mainProgram = "mtk";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "MTK reverse engineering and flash tool";
    homepage = "https://github.com/bkerler/mtkclient";
    license = with lib.licenses; [ gpl3Only ];
  };
}
