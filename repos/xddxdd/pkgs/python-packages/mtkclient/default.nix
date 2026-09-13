{
  fetchFromGitHub,
  lib,
  unstableGitUpdater,
  python3,
  buildPythonPackage,
  keystone,
  # Dependencies
  capstone,
  colorama,
  flake8,
  fusepy,
  keystone-engine,
  hatchling,
  mfusepy,
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
buildPythonPackage (finalAttrs: {
  pname = "mtkclient";
  version = "2.1.4.1-unstable-2026-09-12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "bkerler";
    repo = "mtkclient";
    rev = "cd25cf9c1ff6d36e82697ac2c798e69e9cfb78c3";
    hash = "sha256-k3Ktj8KcNzjIUQKQo8cPM8qazXDKKZhTg3VMPBjfXJU=";
  };
  buildInputs = [ keystone ];
  propagatedBuildInputs = [
    capstone
    colorama
    flake8
    fusepy
    keystone-engine
    hatchling
    mfusepy
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

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/bkerler/mtkclient";
    tagPrefix = "v";
    shallowClone = false;
  };
  meta = {
    changelog = "https://github.com/bkerler/mtkclient/releases/tag/${finalAttrs.version}";
    mainProgram = "mtk";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "MTK reverse engineering and flash tool";
    homepage = "https://github.com/bkerler/mtkclient";
    license = with lib.licenses; [ gpl3Only ];
  };
})
