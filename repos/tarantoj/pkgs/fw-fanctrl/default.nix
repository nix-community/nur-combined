{
  pkgs,
  python3Packages,
}: let
  pname = "fw-fanctrl";
  rev = "43cade936c81e214173307c4aa0e839ef8291026";
in
  python3Packages.buildPythonPackage {
    inherit pname;
    version = rev;
    src = pkgs.fetchFromGitHub {
      inherit rev;
      owner = "TamtamHero";
      repo = "fw-fanctrl";
      hash = "sha256-WBg7YXiCtXLQyWyJEEyOSUN1OeDHe7/tPiKM5QUUz1E=";
    };

    propagatedBuildInputs =
      (with python3Packages; [watchdog])
      ++ (with pkgs; [
        bash
        lm_sensors
        fw-ectool
      ]);

    preBuild =
      /*
      python
      */
      ''
        cat > setup.py << EOF
        from setuptools import setup

        with open('requirements.txt') as f:
          install_requires = f.read().splitlines()

        setup(
          name='fw-fanctrl',
          #packages=['someprogram'],
          version='0.0.1',
          #author='...',
          #description='...',
          install_requires=install_requires,
          scripts=[
            'fanctrl.py',
          ],
          # entry_points={
          #   # example: file some_module.py -> function main
          #   #'console_scripts': ['someprogram=some_module:main']
          # },
        )
        EOF
      '';

    postPatch = ''
      substituteInPlace fanctrl.py --replace /bin/bash ${pkgs.bash}/bin/bash
    '';

    meta = with pkgs.lib; {
      description = "A simple service to better control Framework Laptop's fan";
      license = licenses.bsd3;
      homepage = "https://github.com/TamtamHero/fw-fanctrl";
      changelog = "https://github.com/TamtamHero/fw-fanctrl/commits/main/";
      platforms = intersectLists platforms.x86_64 platforms.linux;
      mainProgram = "fanctrl.py";
    };
  }
