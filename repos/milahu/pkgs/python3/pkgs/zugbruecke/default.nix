{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "zugbruecke";
  version = "0.2.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pleiszenburg";
    repo = "zugbruecke";
    rev = "v${version}";
    hash = "sha256-UsMlnLtyCLSQ+amDANKONoh2zWihQNFgHD1vDn5SeRQ=";
  };

  # TODO is tempdir always /tmp/wenv-3affa2b4/Lib/site-packages/wenv

  # wrong:      '["${python3.pkgs.wenv}/bin/wenv", sys.executable' \
  patchPhase = ''
    substituteInPlace src/zugbruecke/core/interpreter.py \
      --replace-fail \
        '["wenv", "python"' \
        '["${python3.pkgs.wenv}/bin/wenv", "python"' \

    substituteInPlace src/zugbruecke/core/config.py \
      --replace-fail \
        'from wenv import PythonVersion' \
        "$(
          echo 'from wenv import PythonVersion'
          echo 'import wenv'
        )" \
      --replace-fail \
        "return PythonVersion(self['arch'], " \
        'return PythonVersion.from_config(self["arch"], wenv._default_pythonversion) # ' \
      --replace-fail \
        '        if key == "arch":' \
        "$(
          echo '        if key == "arch":'
          echo '            return wenv._default_arch'
        )" \

    # patch src/zugbruecke/core/wenv.py
    patch -p1 <${./fix-sitepackages-paths.patch}
  '';

  nativeBuildInputs = [
    python3.pkgs.flit-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    wenv
  ];

  makeWrapperArgs = [
    "--prefix" "PATH" ":" (lib.makeBinPath [ python3.pkgs.wenv ])
  ];

  passthru.optional-dependencies = with python3.pkgs; {
    dev = [
      flit
      jinja2
      myst-parser
      python-lsp-server
      sphinx
      sphinx-autodoc-typehints
      sphinx-rtd-theme
      toml
      twine
    ];
    test = [
      coverage
      hypothesis
      numpy
      pytest
      pytest-cov
      typeguard
    ];
  };

  pythonImportsCheck = [ "zugbruecke" ];

  /*
  postInstall = ''
    PYTHONPATH=${wenv}/lib/python3.11/site-packages:$out/lib/python3.11/site-packages \
    python -c "$(
    cat <<EOF
    import os
    #os.environ["WENV_PREFIX"] = os.environ["HOME"] + "/.cache/wenv"
    import zugbruecke.ctypes as ctypes
    dll_pow = ctypes.cdll.msvcrt.pow
    dll_pow.argtypes = (ctypes.c_double, ctypes.c_double)
    dll_pow.restype = ctypes.c_double
    print(f'You should expect "1024.0" to show up here: "{dll_pow(2.0, 10.0):.1f}".')
    EOF
  '';
  */

  meta = with lib; {
    description = "Calling routines in Windows DLLs from Python scripts running under Linux, MacOS or BSD";
    homepage = "https://github.com/pleiszenburg/zugbruecke";
    changelog = "https://github.com/pleiszenburg/zugbruecke/blob/${src.rev}/CHANGES.rst";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ ];
    mainProgram = "zugbruecke";
  };
}
