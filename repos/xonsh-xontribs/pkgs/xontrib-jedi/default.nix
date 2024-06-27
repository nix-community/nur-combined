{
  pkgs,
  python3,
}: let
  pname = "xontrib-jedi";
  version = "0.0.2";
in
  python3.pkgs.buildPythonPackage {
    inherit pname version;

    src = pkgs.fetchFromGitHub {
      owner = "xonsh";
      repo = "xontrib-jedi";
      rev = "10c6ee341f65812a06145d097b06ace8bc2cf154";
      sha256 = "sha256-cVlom9Ez3kxZTgm3dWfAJQ+DdhuACM76p6NvbyPrLyc=";
    };

    doCheck = false;

    nativeBuildInputs = with pkgs; [
      python3Packages.setuptools
      python3Packages.wheel
    ];

    patchPhase = ''
      echo "from setuptools import setup" > setup.py
      echo "setup(" >> setup.py
      echo "    name='${pname}'," >> setup.py
      echo "    packages=['xontrib']," >> setup.py
      echo "    package_dir={'xontrib': 'xontrib'}," >> setup.py
      echo "    package_data={'xontrib': ['*.xsh']}," >> setup.py
      echo "    zip_safe=False" >> setup.py
      echo ")" >> setup.py
    '';

    meta = {
      homepage = "https://github.com/xonsh/xontrib-jedi";
      license = ''
        MIT
      '';
      description = "[how-to use in nix](https://github.com/drmikecrowe/nur-packages) Xonsh Python completions using [jedi](https://jedi.readthedocs.io/en/latest/).";
    };
  }
