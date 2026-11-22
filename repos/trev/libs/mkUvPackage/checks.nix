{
  pkgs,
}:

let
  inherit (pkgs) lib;

  # depends on greenlet, a C++ extension, and on pywin32 on windows only, which
  # has no other wheels. pytest is in the dev group
  src = builtins.path {
    name = "source";
    path = ./fixture;
  };

  # different sources, read during evaluation without building them
  srcWithoutTests = builtins.path {
    name = "source";
    path = ./fixture;
    filter = path: _: baseNameOf path != "tests";
  };

  mkFixture =
    args:
    pkgs.mkUvPackage (
      {
        inherit src;
        groups = [ "dev" ];
        meta.mainProgram = "fixture";
      }
      // args
    );

  fixture = mkFixture {
    # the tests ran
    postCheck = ''
      test -d .pytest_cache
    '';
  };

  withoutTests = mkFixture {
    src = srcWithoutTests;
    doCheck = false;
  };

  python313 = mkFixture {
    python = pkgs.python313;
  };

  freeThreading = mkFixture {
    python = pkgs.python314FreeThreading;
  };

  # greenlet built from source by nixpkgs
  overridden = mkFixture {
    overrides.greenlet = pkgs.python3Packages.greenlet;
  };

  # no build system, only the dependencies are installed
  virtual = pkgs.mkUvPackage {
    src = builtins.path {
      name = "source";
      path = ./fixture-virtual;
    };
  };

  # the lock passed separately is copied over the source's. With build-system
  # nothing is read from the source during evaluation. nixpkgs' uv-build is older
  # than pyproject.toml requires, which isn't checked
  separateLock = mkFixture {
    src = pkgs.runCommand "source" { } ''
      cp -r ${src} $out
      chmod -R u+w $out
      rm $out/uv.lock
    '';
    lock = ./fixture/uv.lock;
    build-system = [ pkgs.python3Packages.uv-build ];
  };

  wheelNames = package: map (wheel: wheel.name) package.uvWheels;

  # the wheels picked for other interpreters and platforms
  pickWheels = import ../uvHook/wheels.nix { inherit lib; };
  picked =
    args:
    map (wheel: wheel.filename) (
      pickWheels (
        {
          lock = lib.importTOML ./fixture/uv.lock;
          python = pkgs.python314;
          platform = lib.systems.elaborate "x86_64-linux";
          libcVersion = "2.42";
        }
        // args
      )
    );
  greenletPicked = args: lib.filter (lib.hasPrefix "greenlet-") (picked args);
in
assert fixture.pname == "fixture";
assert fixture.version == "1.0.0";
# the wheels don't change with the sources
assert fixture.uvWheelIndex.outPath == withoutTests.uvWheelIndex.outPath;
assert fixture.outPath != withoutTests.outPath;
assert builtins.any (lib.hasPrefix "greenlet-") (wheelNames fixture);
assert builtins.any (lib.hasPrefix "pytest-") (wheelNames fixture);
assert !builtins.any (lib.hasPrefix "pywin32-") (wheelNames fixture);
assert !builtins.any (lib.hasPrefix "greenlet-") (wheelNames overridden);
assert virtual.pname == "fixture-virtual";
assert virtual.uvBuildPython == "";
assert
  greenletPicked { }
  == [ "greenlet-3.5.6-cp314-cp314-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl" ];
assert
  greenletPicked { python = pkgs.python313; } == [
    "greenlet-3.5.6-cp313-cp313-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl"
  ];
assert
  greenletPicked { python = pkgs.python314FreeThreading; } == [
    "greenlet-3.5.6-cp314-cp314t-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl"
  ];
assert
  greenletPicked { platform = lib.systems.elaborate "aarch64-linux"; } == [
    "greenlet-3.5.6-cp314-cp314-manylinux_2_24_aarch64.manylinux_2_28_aarch64.whl"
  ];
assert
  greenletPicked { platform = lib.systems.elaborate "aarch64-darwin"; } == [
    "greenlet-3.5.6-cp314-cp314-macosx_11_0_universal2.whl"
  ];
# too old for manylinux_2_24
assert greenletPicked { libcVersion = "2.17"; } == [ ];
# musllinux isn't supported
assert greenletPicked { platform = lib.systems.elaborate "x86_64-unknown-linux-musl"; } == [ ];
# PyPy only gets pure wheels
assert builtins.elem "pytest-9.2.0-py3-none-any.whl" (picked {
  python = pkgs.pypy3;
});
assert greenletPicked { python = pkgs.pypy3; } == [ ];
{
  build = pkgs.runCommand "mkUvPackage-build" { } ''
    test "$(${lib.getExe fixture})" = "hello from greenlet"
    test "$(${lib.getExe withoutTests})" = "hello from greenlet"
    test "$(${lib.getExe python313})" = "hello from greenlet"
    test "$(${lib.getExe freeThreading})" = "hello from greenlet"
    test "$(${lib.getExe overridden})" = "hello from greenlet"
    test "$(${lib.getExe separateLock})" = "hello from greenlet"
    ${virtual}/bin/python -c 'import greenlet'

    # the dependency groups are only installed for the check phase
    test ! -e ${fixture}/bin/pytest
    if ${fixture}/bin/python -c 'import pytest' 2> /dev/null; then
      echo "pytest was installed" >&2
      exit 1
    fi

    # the interpreter is free-threaded
    test "$(${freeThreading}/bin/python -c 'import sys; print(sys._is_gil_enabled())')" = False
    touch $out
  '';
}
