let
  src = {
    owner = "polybar";
    repo = "polybar-scripts";
    rev = "8a6a2c7fc6beb281515f81ccf5b9fafc830a3230";
    sha256 = "sha256-4f12SSidJGElPbHs94WyoKj9kJH4dWsZSqMGOyzSJII=";
    version = "2024.05.21";
  };
in {
  player-mpris-tail = {
    python3Packages
  , lib, fetchFromGitHub
  , gobject-introspection, wrapGAppsHook3
  , pip ? buildPackages.python3Packages.pip, buildPackages
  }: let
    sourceRoot = "source/polybar-scripts/player-mpris-tail";
  in python3Packages.buildPythonApplication {
    pname = "mpris-tail";
    inherit (src) version;

    inherit sourceRoot;
    src = fetchFromGitHub {
      inherit (src) owner repo rev sha256;
    };
    format = "setuptools";

    propagatedBuildInputs = with python3Packages; [
      dbus-python
      pygobject3
    ];

    nativeBuildInputs = [
      pip
      gobject-introspection
      wrapGAppsHook3
    ];

    passAsFile = [ "setup" ];
    setupRequirements = ["dbus-python" "pygobject"];
    setup = ''
      import os
      from setuptools import find_packages, setup
      setup(
        name='@pname@',
        version='@version@',
        install_requires=os.environ["setupRequirements"].split(),
        packages=find_packages(),
        scripts=['player-mpris-tail.py'],
      )
    '';
    postPatch = ''
      substituteAll $setupPath setup.py
    '';

    meta = {
      description = "Displays the current track and the play-pause status without polling";
      homepage = "https://github.com/${src.owner}/${src.repo}/tree/master/${sourceRoot}";
      mainProgram = "player-mpris-tail.py";
    };
  };
}
