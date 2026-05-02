# needed for ./pkgs/python3/pkgs/pyload/pyload.nix

{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  python,
  setuptools,
  fetchgit,
  git,
  gn,
  nodejs-slim, # TODO remove
  skia-aseprite, # icudtl.dat (784 KB)
  v8,
}:

buildPythonPackage (finalAttrs: {
  pname = "mini-racer";
  version = "0.14.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "bpcreech";
    repo = "PyMiniRacer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oayWmjIo5CTKXGa1RtGK8nxzOEfwrHb6i67eXpI5iM0=";
  };

  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/web/nodejs/nodejs.nix
  mini-racer-lib = v8.overrideAttrs (oldAttrs: {
    pname = "libmini_racer";
    postUnpack = (oldAttrs.postUnpack or "") + ''
      ln -v -s ${finalAttrs.src}/src/v8_py_frontend $sourceRoot/custom_deps/mini_racer
    '';
    gnFlags = (oldAttrs.gnFlags or [ ]) ++ [
      # https://github.com/bpcreech/PyMiniRacer/blob/main/builder/v8_build.py

      # These following settings are based those found for the "x64.release"
      # configuration. This can be verified by running:
      # tools/mb/mb.py lookup -b x64.release -m developer_default
      # ... from within the v8 directory.
      "is_debug=false"

      # these are already set in v8/default.nix
      # "v8_use_external_startup_data=false"
      # "v8_monolithic=true"

      # From https://groups.google.com/g/v8-users/c/qDJ_XYpig_M/m/qe5XO9PZAwAJ:
      "v8_monolithic_for_shared_library=true"

      # ''target_cpu="${target_cpu}"''
      # ''v8_target_cpu="${target_cpu}"''

      # We sneak our C++ frontend into V8 as a symlinked "custom_dep" so
      # that we can reuse the V8 build system to make our dynamic link
      # library:
      ''v8_custom_deps="//custom_deps/mini_racer"''
    ];
    installPhase = ''
      mkdir -p $out/lib
      cp -v libmini_racer.so $out/lib
    '';
  });

  build-system = [
    setuptools
  ];

  preBuild = ''
    # https://github.com/bpcreech/PyMiniRacer/blob/main/setup.py
    ln -s ${finalAttrs.mini-racer-lib}/lib/libmini_racer.* src/py_mini_racer
  '';

  postInstall = ''
    # fix: py_mini_racer._dll.LibNotFoundError:
    # Native library or dependency not available at
    # /lib/python3.13/site-packages/py_mini_racer/icudtl.dat
    cp -v ${skia-aseprite}/third_party/externals/icu/flutter/icudtl.dat \
      $out/${python.sitePackages}/py_mini_racer
  '';

  checkPhase = ''
    PYTHONPATH=$out/${python.sitePackages} \
    python -c '
    import py_mini_racer
    ctx = py_mini_racer.MiniRacer()
    s = "1+1"
    print(f"ctx.eval: {s}:", ctx.eval(s))
    s = "[1,2,3].includes(5)"
    print(f"ctx.execute: {s}:", ctx.execute(s))
    # we have to ctx.close otherwise this hangs
    ctx.close()
    '
  '';

  pythonImportsCheck = [
    "py_mini_racer"
  ];

  meta = {
    description = "V8 bridge in Python";
    homepage = "https://github.com/bpcreech/PyMiniRacer";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ ];
  };
})

# TODO build mini-racer/src/v8_py_frontend in isolation
# and link it to an existing libnode.so

/*
  mini-racer-lib-broken = nodejs-slim.overrideAttrs (oldAttrs: {
    pname = "mini-racer-lib";
    outputs = [ "out" ];

    configureFlags = oldAttrs.configureFlags ++ [
      # https://github.com/nodejs/node/commit/f21c2b9d3b4595d63e7f9ebd88b9d5fc964131fb
      # also build libnode.so
      # FIXME this fails with
      # AttributeError: /lib/python3.13/site-packages/py_mini_racer/libmini_racer.so:
      # undefined symbol: mr_init_v8
      "--shared"
    ];

    postUnpack = ''
      # finalAttrs.src = mini-racer.src
      # https://github.com/bpcreech/PyMiniRacer/blob/main/builder/v8_build.py
      # def ensure_v8_src
      ln -v -s ${finalAttrs.src}/src/v8_py_frontend $sourceRoot/deps/v8/custom_deps/mini_racer

      # mock output paths
      libv8=$out
      npm=$out
      corepack=$out
      dev=$out
    '';

    # fix: Segmentation fault
    doCheck = false;

    # TODO? also install headers
    # usually headers are not needed
    # mini-racer/setup.py only requires libmini_racer.so
    /*
      # install the missing headers for node-gyp
      # TODO: use propagatedBuildInputs instead of copying headers.
      cp -r ${lib.concatStringsSep " " copyLibHeaders} $out/include/node

      # copy v8 headers
      cp -r deps/v8/include $libv8/
    *xxx/
    installPhase = ''
      mkdir -p $out/lib
      # so.137
      shlib_suffix=$(grep -m1 shlib_suffix config.gypi | cut -d\" -f4)
      # so
      short_suffix=$(echo $shlib_suffix | sed -E 's/\.[0-9]+$//')
      cp -v out/Release/lib/libnode.$shlib_suffix $out/lib/libmini_racer.$short_suffix

      # fix: py_mini_racer._dll.LibNotFoundError:
      # Native library or dependency not available at
      # /lib/python3.13/site-packages/py_mini_racer/icudtl.dat
      set -x
      find . -name '*icudtl.dat*'
    '';

    # fix: error: derivation output check for 'out' contains output name 'corepack',
    # but this is not a valid output of this derivation. (Valid outputs are [out].)
    outputChecks = null;
  });
*/
