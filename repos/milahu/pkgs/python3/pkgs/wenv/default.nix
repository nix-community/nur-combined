/*

  test

  ./result/bin/wenv init
  ./result/bin/wenv python -c "import sys; print(sys.platform)"

  ... should print "win32"

  hint: to exit the windows python shell, use Ctrl+Z and Enter

*/

{ lib
, python3
, fetchFromGitHub
, fetchurl
, wine
, wine64
, fetchPypi
, get-pip
}:

python3.pkgs.buildPythonApplication rec {
  pname = "wenv";
  version = "0.5.1";
  pyproject = true;

  defaultArch = "win32";
  defaultPythonVersion = python3-win32-zip.version;
  wenvCache = "share/wenv/cache";

  src = fetchFromGitHub {
    owner = "pleiszenburg";
    repo = "wenv";
    rev = "v${version}";
    hash = "sha256-ioroNFNnNZx+UjEi+yAynqCD6sDSScIG9a/I5JYnyf0=";
  };

  # based on wenv/_core/pythonversion.py
  python3-win32-zip = fetchurl rec {
    version = "3.11.7";
    name = "python-${version}-embed-win32.zip";
    url = "https://www.python.org/ftp/python/${version}/${name}";
    hash = "sha256-RHgGJP56Wd5CkEz3BuW19OJP3GUWUAYMnEqA7XnmhHw=";
    passthru = {
      inherit version;
    };
  };

  python3-amd64-zip = fetchurl rec {
    version = "3.11.7";
    name = "python-${version}-embed-amd64.zip";
    url = "https://www.python.org/ftp/python/${version}/${name}";
    hash = "sha256-pSiLY7YhiQLpGE11tasqqh03uKpXCYGTRk1qSKugFJY=";
    passthru = {
      inherit version;
    };
  };

  pip-whl = fetchPypi {
    pname = "pip";
    version = "24.0";
    hash = "sha256-ug0CGhZoZdImUkaWG+wBUv8STekQxcw58RVs4/p8adw=";
    format = "wheel";
    dist = "py3";
    python = "py3";
    platform = "any";
  };

  setuptools-whl = fetchPypi {
    pname = "setuptools";
    version = "69.5.1";
    hash = "sha256-xjasNhvEdYBQRkQnXJrYAsUEFcdSIhIlLAM70V8wHzI=";
    format = "wheel";
    dist = "py3";
    python = "py3";
    platform = "any";
  };

  wheel-whl = fetchPypi {
    pname = "wheel";
    version = "0.43.0";
    hash = "sha256-VcVwQF8UJjDGufcv4J2bZ88Ud/z1Q65bjcsfW3N32oE=";
    format = "wheel";
    dist = "py3";
    python = "py3";
    platform = "any";
  };

  /*
    by default, wenv picks the read-only /nix/store as prefix

    wenv/_core/config.py install_location '/nix/store/irb3bcwhjq2gwavxaxdz5hxmsp7sk2vr-wenv-0.5.1/lib/python3.11/site-packages/wenv/_core/config.py'
    wenv/_core/config.py site.USER_BASE '/home/user/.local'

    patch this:

        if key == "prefix":
            install_location = os.path.abspath(__file__)

    this is only the default prefix
    you can change it by setting WENV_PREFIX
  */

  patchPhase = ''
    substituteInPlace src/wenv/_core/config.py \
      --replace-fail \
        'install_location = os.path.abspath(__file__)' \
        'return os.environ["HOME"] + "/.cache/wenv"' \
      --replace-fail \
        '        if key == "no_pth_file":' \
        "$(
          echo '        if key == "wenv_bin":'
          #echo '            return "wenv"'
          echo '            return "'$out'/bin/wenv"'
          echo '        if key == "no_pth_file":'
        )" \
      --replace-fail \
        '        if key == "arch":' \
        "$(
          echo '        if key == "arch":'
          echo '            return "${defaultArch}"'
        )" \
      --replace-fail \
        '        if key == "offline":' \
        "$(
          echo '        if key == "offline":'
          echo '            return True'
        )" \
      --replace-fail \
        "return PythonVersion(self['arch'], " \
        'return PythonVersion.from_config(self["arch"], "${defaultPythonVersion}") # ' \
      --replace-fail \
        '        if key == "wine_bin_win32":' \
        "$(
          echo '        if key == "wine_bin_win32":'
          echo '            return "${wine}/bin/wine"'
        )" \
      --replace-fail \
        '        if key == "wine_bin_win64":' \
        "$(
          echo '        if key == "wine_bin_win64":'
          echo '            return "${wine64}/bin/wine64"'
        )" \
      --replace-fail \
        '        if key == "cache":' \
        "$(
          echo '        if key == "cache":'
          #echo '            return "'$out'/${wenvCache}"'
          # use the default wenv cache only when reading from cache
          # when writing to cache, use the original default cache
          # os.path.join(self["prefix"], "share", "wenv", "cache")
          #echo '            if self._cmd != "cache": return "'$out'/${wenvCache}"'
          # quick hack:
          echo '            if len(sys.argv) < 2 or sys.argv[1] != "cache": return "'$out'/${wenvCache}"'
        )" \

    substituteInPlace src/wenv/_core/env.py \
      --replace-fail \
        '"wenv",' \
        'self._p["wenv_bin"],' \
      ${""/*
        fix: wine: '/home/user/.cache/wenv/share/wenv/win64' is a 32-bit installation, it cannot support 64-bit applications.
        but still, this does not work with arch = "win64"...

        wine: failed to open L"C:\\windows\\syswow64\\rundll32.exe": c0000135
        wine: failed to load L"\\??\\C:\\windows\\syswow64\\ntdll.dll" error c0000135

        /home/user/.cache/wenv/share/wenv/win64/drive_c/windows/syswow64/ is empty
      */} \
      --replace-fail \
        '"wine",' \
        'self._wine_dict[self._p["arch"]],' \

    ${""/*
      # no. Env.cli is called after Env.__init__

      # TODO refactor "class Env" in wenv/_core/env.py
      # move code from __init__ to cli
      # so that "class EnvConfig" in wenv/_core/config.py
      # can see the "cmd" from cli
      # so we can have different default configs for different cli commands
      # but no... better to make the "cache" config a list of paths:

      # ideally the "cache" config should be a list of paths
      # for reading from the cache, all cache paths are used
      # for writing to the cache, the first writable cache path is used

      --replace-fail \
        '        if cmd in self._cli_dict.keys():' \
        "$(
          echo '        self._cmd = cmd'
          echo '        if cmd in self._cli_dict.keys():'
        )" \
    */}

    # needed for zugbruecke/core/config.py
    cat >>src/wenv/__init__.py <<EOF
    _default_pythonversion = "${defaultPythonVersion}"
    _default_arch = "${defaultArch}"
    EOF
  '';

  # TODO patch wenv/_core/pythonversion.py to handle different platforms: 32bit vs 64bit

  # why python version 3.7.4? -> search for (3, 7, 4) in wenv sources

  # no. ignore python version
  /*
  python3-site-py = fetchurl rec {
    inherit (python3-win32-zip) version;
    name = "site.py";
    url = "https://raw.githubusercontent.com/python/cpython/v${version}//Lib/site.py";
    hash = "sha256-aAM5a6Bxnk0dbOk1HwnwvKEauOnE7+D5NfWY2o6LkD4=";
    passthru = {
      inherit version;
    };
  };
  */

  # no. the url is not stable
  # this is just a fancy way to install pip
  /*
  get-pip-py = fetchurl rec {
    name = "get-pip.py";
    url = "https://bootstrap.pypa.io/get-pip.py";
    hash = "sha256-3+n9XCjcmLWsF5ealT6lUM7DeuG0elEWAHOVv6z/Krk=";
  };
  */

  # not used
  # https://github.com/pleiszenburg/wenv/issues/25
  # wenv cache should only cache whl files, not tgz files
  /*
  pip-tgz = fetchPypi {
    pname = "pip";
    version = "24.0";
    hash = "sha256-6pvRqEfoxXdKV3e7OYwZ6AvNTiqhakswG3GP5vWTq6I=";
  };

  setuptools-tgz = fetchPypi {
    pname = "setuptools";
    version = "69.5.1";
    hash = "sha256-bB/M2sBal+WY+wrju+1ZBMyzFzN6UROdzVFFNhG7uYc=";
  };

  wheel-tgz = fetchPypi {
    pname = "wheel";
    version = "0.43.0";
    hash = "sha256-Rl75LGn6XF2i0c+KxAVZqMlAiGr874fc8UuUcIYvHYU=";
  };
  */

  /*
    TODO create a custom get-pip.py to install these files
    use symlinks to make it smaller and faster
    ls ~/.cache/wenv/share/wenv/win32/drive_c/python-3.11.7.stable/Scripts/
    pip3.11.exe  pip3.exe  pip.exe  wheel.exe

    https://pip.pypa.io/en/stable/installation/
  */

  /*
    cat >wenv-cache/get-pip.py <<EOF
    #!/usr/bin/env python3
    import sys
    import os
    dst = "$out/share/wenv/win32/drive_c/python-${python3-win32-zip.version}.stable/Lib/site-packages"
    print(f"get-pip.py: creating directory {repr(dst)}")
    os.makedirs(dst, exist_ok=True)
    src = "${python3.pkgs.pip}/${python3.sitePackages}"
    name = "pip"
    distinfo = name + "-${python3.pkgs.pip.version}.dist-info"
    for path in [name, distinfo]:
      a = src + "/" + path
      b = dst + "/" + path
      print(f"get-pip.py: creating symlink: {repr(b)} -> {repr(a)}")
      os.symlink(a, b)
    print(f"get-pip.py: done")
    EOF
  */

  # no. these defaults only affect the wenv CLI
  # but not the wenv python module
  # -> substituteInPlace src/wenv/_core/config.py
  /*
  makeWrapperArgs = [
    "--set-default" "WENV_ARCH" "win32"
    "--set-default" "WENV_PYTHONVERSION" python3-win32-zip.version
    "--set-default" "WENV_WINE_BIN_WIN32" "${wine}/bin/wine"
    "--set-default" "WENV_WINE_BIN_WIN64" "${wine64}/bin/wine64"
    "--set-default" "WENV_OFFLINE" "1"
    "--set-default" "WENV_CACHE" "$out/${wenvCache}"
    # the original wenv/_core/env.py tries to call "wenv"
    # but that is not in PATH when using wenv in python
    "--set-default" "WENV_WENV_BIN" "$out/bin/wenv"
    # no. WENV_PREFIX must be writable
    #"--set-default" "WENV_PREFIX" "$out/..."
  ];
  */

  postPhases = "postDist";

  # setup environment: Wine prefix, Python interpreter, pip, setuptools, wheel
  #  ln -s ${python3-site-py} wenv-cache/${python3-site-py.name}
  #postInstall = # too early. $out/bin/wenv is not-yet wrapped
  postDist =
  /*
    no. this does not work because wine throws a fatal error
    if the WINEPREFIX is not owned by the current user

    we cannot use "sudo" because files in /nix/store are owned by root

    https://github.com/pleiszenburg/wenv/issues/22#issuecomment-2061529176

    this will not work with unpatched wine

    [wine/libs/wine/config.c](https://github.com/vindo-app/wine/blob/master/libs/wine/config.c)

    ```c
        if (st.st_uid != getuid()) fatal_error( "%s is not owned by you\n", config_dir );
    ```

    wine complains about the ownership of WINEPREFIX

    ```
    $ ./result/bin/wenv python
    wine: '/nix/store/mcbrxyi2q7kksyrxm7px9l0ik3rxv94h-wenv-0.5.1/share/wenv/win32' is not owned by you
    ```

    > WINEPREFIX is not owned by you

    i found many discussions on this problem
    but no solution to make wine ignore the ownership
    workarounds: sudo, chown, symlinks, bind mount, LD_PRELOAD, ...
  */
  if false then
  ''
    mkdir wenv-cache
    ln -s -v ${python3-win32-zip} wenv-cache/${python3-win32-zip.name}
    ln -s -v ${python3-amd64-zip} wenv-cache/${python3-amd64-zip.name}
    ln -s -v ${python3}/${python3.sitePackages}/../site.py wenv-cache/site.py

    #mkdir wenv-cache/packages

    cat >wenv-cache/get-pip.py <<EOF
    #!/usr/bin/env python3
    print("get-pip.py: noop")
    EOF

    ${""/*
      set WENV_PREFIX
      fix: OSError: [Errno 30] Read-only file system: '/nix/store/12hx5iv7v4jw64p4fwzx2cjwpdzh2gpf-python3-3.11.7-env/share/wenv'
      https://github.com/pleiszenburg/wenv/issues/22

      set HOME
      fix: Fontconfig error: No writable cache directories

      todo
      set FONTCONFIG_PATH
      fix: Fontconfig error: Cannot load default config file: No such file: (null)

      wenv init:
      wineprefixcreate --prefix $out/share/wenv/win32
      mkdir -p $out/share/wenv/win32/drive_c
      pushd $out/share/wenv/win32/drive_c
      unzip ${python3-win32-zip}
      popd
      (... and maybe more)

    */}

    # TODO move these envs to the wrapper of $out/bin/wenv
    # these envs are used in wenv/_core/config.py
    echo "running 'wenv init' to setup the wine environment in $out/share/wenv"
    WENV_OFFLINE=1 \
    WENV_CACHE=$PWD/wenv-cache \
    PATH=$PATH:${wine}/bin:$out/bin \
    HOME=$TMP \
    $out/bin/wenv init

    # fixup: manually install python modules
    # TODO "cp -r -s" the .py files and create __pycache__ dirs for windows
    ln -s -v \
      -t $out/share/wenv/win32/drive_c/python-${python3-win32-zip.version}.stable/Lib/site-packages/ \
      ${python3.pkgs.pip}/${python3.sitePackages}/* \
      ${python3.pkgs.setuptools}/${python3.sitePackages}/* \
      ${python3.pkgs.wheel}/${python3.sitePackages}/* \
  ''
  else

  # instead, only populate the wenv cache, so "wenv init" works offline

  # "wenv init" uses only the whl files from cache

  ''
    mkdir -p $out/$wenvCache
    pushd $out/$wenvCache
    ln -s -v ${python3-win32-zip} ${python3-win32-zip.name}
    ln -s -v ${python3-amd64-zip} ${python3-amd64-zip.name}
    # TODO verify. python-3.11.7.stable/Lib/site.py already exists
    # see also https://github.com/pleiszenburg/wenv/issues/25
    ln -s -v ${python3}/${python3.sitePackages}/../site.py site.py
    # run "GET_PIP_OFFLINE=1 get-pip-generate" to generate public/get-pip.py
    GET_PIP_OFFLINE=1 ${get-pip}/bin/get-pip-generate
    mv public/get-pip.py get-pip.py
    rm public/pip.pyz
    rmdir public
    popd

    mkdir -p $out/$wenvCache/packages
    pushd $out/$wenvCache/packages
    ln -s -v ${pip-whl} ${pip-whl.name}
    ln -s -v ${setuptools-whl} ${setuptools-whl.name}
    ln -s -v ${wheel-whl} ${wheel-whl.name}
    popd
  '';

  nativeBuildInputs = [
    python3.pkgs.flit-core
  ];

  passthru.optional-dependencies = with python3.pkgs; {
    dev = [
      black
      coverage
      myst-parser
      pytest
      pytest-cov
      python-lsp-server
      sphinx
      sphinx-autodoc-typehints
      sphinx-rtd-theme
      twine
      typeguard
    ];
  };

  pythonImportsCheck = [ "wenv" ];

  meta = with lib; {
    description = "Running Python on Wine";
    homepage = "https://github.com/pleiszenburg/wenv";
    changelog = "https://github.com/pleiszenburg/wenv/blob/${src.rev}/CHANGES.md";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ ];
    mainProgram = "wenv";
  };
}
