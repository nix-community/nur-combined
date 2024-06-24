{
  pkgs,
  python3,
}: let
  pname = "xontrib-gitinfo";
  version = "0.1.0";
in
  python3.pkgs.buildPythonPackage {
    inherit pname version;

    src = pkgs.fetchFromGitHub {
      owner = "dyuri";
      repo = "xontrib-gitinfo";
      rev = "b1ba458d85a6684088807d962b39980144685630";
      sha256 = "sha256-e5lgfcrG8p/3YgYNlnkfZIYj3VEjuNTRoseAl+Uyfd8=";
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

    dependencies = [
      pkgs.onefetch
    ];

    meta = {
      homepage = "https://github.com/dyuri/xontrib-gitinfo";
      license = ''
        MIT
      '';
      description = "xonsh gitinfo";
    };
  }
