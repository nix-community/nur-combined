{
  pkgs,
}:

let
  inherit (pkgs) lib;

  # depends on greenlet, a C++ extension, and on pywin32 on windows only. pytest
  # is in the dev group
  src = ../mkUvPackage/fixture;

  env = pkgs.mkUvEnv {
    inherit src;
    groups = [ "dev" ];
  };

  # only uv.lock and pyproject.toml are inputs
  fromFiles = pkgs.mkUvEnv {
    lock = src + "/uv.lock";
    pyproject = src + "/pyproject.toml";
    groups = [ "dev" ];
  };

  # the project is found in $FIXTURE_ROOT when Python starts
  editable = pkgs.mkUvEnv {
    inherit src;
    groups = [ "dev" ];
    editableRoot = "$FIXTURE_ROOT";
  };

  withoutGroups = pkgs.mkUvEnv {
    inherit src;
  };

  # greenlet built from source by nixpkgs
  overridden = pkgs.mkUvEnv {
    inherit src;
    overrides.greenlet = pkgs.python3Packages.greenlet;
  };

  freeThreading = pkgs.mkUvEnv {
    inherit src;
    python = pkgs.python314FreeThreading;
  };

  virtual = pkgs.mkUvEnv {
    src = ../mkUvPackage/fixture-virtual;
  };

  wheelNames = package: map (wheel: wheel.name) package.uvWheels;
in
assert env.pname == "fixture-env";
assert env.version == "1.0.0";
assert lib.getExe env == "${env}/bin/python";
assert env.drvPath == fromFiles.drvPath;
assert builtins.any (lib.hasPrefix "greenlet-") (wheelNames env);
assert !builtins.any (lib.hasPrefix "greenlet-") (wheelNames overridden);
assert virtual.pname == "fixture-virtual-env";
assert editable.editable.pname == "fixture";
{
  build = pkgs.runCommand "mkUvEnv-build" { } ''
    ${lib.getExe env} -c 'import greenlet, pytest'
    ${lib.getExe overridden} -c 'import greenlet'
    ${lib.getExe virtual} -c 'import greenlet'
    test "$(${lib.getExe freeThreading} -c 'import sys, greenlet; print(sys._is_gil_enabled())')" = False

    # the groups are only installed if they're asked for
    if ${lib.getExe withoutGroups} -c 'import pytest' 2> /dev/null; then
      echo "pytest was installed" >&2
      exit 1
    fi

    # the project is only installed editable
    test ! -e ${env}/bin/fixture
    if ${lib.getExe env} -c 'import fixture' 2> /dev/null; then
      echo "the project was installed" >&2
      exit 1
    fi

    export FIXTURE_ROOT=${src}
    test "$(${editable}/bin/fixture)" = "hello from greenlet"
    # the tests run against the sources, like in a check
    cd ${src}
    ${editable}/bin/pytest -p no:cacheprovider tests

    # pyright finds the dependencies and the project with the environment's
    # python, outside the sources
    cd "$TMPDIR"
    echo 'import greenlet, pytest; from fixture import hello' > imports.py
    HOME=$TMPDIR ${lib.getExe pkgs.pyright} --warnings --pythonpath ${lib.getExe editable} imports.py

    touch $out
  '';
}
