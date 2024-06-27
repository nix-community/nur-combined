{
  pkgs,
  python3,
}: let
  pname = "xontrib-term-integrations";
  version = "0.2.0-alpha1";
in
  python3.pkgs.buildPythonPackage {
    inherit pname version;

    src = pkgs.fetchFromGitHub {
      owner = "jnoortheen";
      repo = "xontrib-term-integrations";
      rev = "c1cf9a8aa72683548e32b59045917c1c8c760fa8";
      sha256 = "sha256-pO4rx4vB2qZwFXtCfwNknLhLhkVBxxOb1hVgICnsVUo=";
    };

    doCheck = false;

    nativeBuildInputs = with pkgs.python3Packages; [
      setuptools
      wheel
      poetry-core
    ];

    patchPhase = ''
      echo "from setuptools import setup" > setup.py
      echo "setup(" >> setup.py
      echo "    name='${pname}'," >> setup.py
      echo "    packages=['xontrib', 'xontrib_term_integrations']," >> setup.py
      echo "    package_dir={'xontrib': 'xontrib', 'xontrib_term_integrations': 'xontrib_term_integrations'}," >> setup.py
      echo "    package_data={'xontrib': ['*.py'], 'xontrib_term_integrations': ['*.py']}," >> setup.py
      echo "    zip_safe=False" >> setup.py
      echo ")" >> setup.py
    '';

    meta = {
      homepage = "https://github.com/jnoortheen/xontrib-term-integrations";
      license = ''
        MIT
      '';
      description = "[how-to use in nix](https://github.com/drmikecrowe/nur-packages) # Terminal Emulators integration";
    };
  }
