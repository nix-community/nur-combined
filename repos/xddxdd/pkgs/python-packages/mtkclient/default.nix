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
  version = "2.1.4.1-unstable-2026-11-20";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "bkerler";
    repo = "mtkclient";
    rev = "a1e1b4d8c68ea6d711e789678f98a256ce848eab";
    hash = "sha256-9B3IkF0a9ocJmYABjOR2R1k9/ilWOk8YHqjcjgDtnck=";
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
