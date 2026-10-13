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
  version = "2.1.4.1-unstable-2026-10-12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "bkerler";
    repo = "mtkclient";
    rev = "7cb40e727727dfe3faa065eefb29b16ed29bbdf1";
    hash = "sha256-JVuGCoUtNtdW26RERVT5Fjs9qvJ1tSl9UF1MieQgJM8=";
  };
  __structuredAttrs = true;
  strictDeps = true;
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
