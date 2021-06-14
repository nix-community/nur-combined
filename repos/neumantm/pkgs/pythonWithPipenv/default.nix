{ stdenv, lib, writeTextDir, buildFHSUserEnv, symlinkJoin,

python, pypi2nix, ctags, 

myPythonDerivation ? python, 
myPythonPackages ? pp:[] 
}:

let
  # include paths for shell profiles
  extraEtcPaths = [
    "bashrc"
    "fish"
    "zprofile"
    "zshenv"
  ];

  pipenv-extra-chrootenv = stdenv.mkDerivation {
    name = "pipenv-extra-chrootenv";
    buildCommand = ''
      mkdir -p $out/etc
      cd $out/etc
    '' + lib.concatMapStrings (path: ''
      ln -s /host/etc/${path} ${path}
    '') extraEtcPaths;
  };

  # manylinux file to mark this distribution as linux compatible for python
  manylinux-file = writeTextDir "_manylinux.py" ''
    print("in _manylinux.py")
    manylinux1_compatible = True
  '';

  pipenvwrapper = buildFHSUserEnv {
    name = "pipenv";

    profile = ''
      source /host/etc/profile
      export PYTHONPATH=${manylinux-file}:/usr/${myPythonDerivation.sitePackages}
    '';

    targetPkgs = p: with p; [
      (myPythonDerivation.withPackages(pp: [ pp.virtualenv ]))
      pipenv
      which
      gcc
      binutils

      # All the C libraries that a manylinux_1 wheel might depend on:
      glib
      libxslt.dev
      libxml2.dev
      ncurses
      rdkafka
      xorg.libX11
      xorg.libXext
      xorg.libXrender
      xorg.libICE
      xorg.libSM
      zlib

      # include shell profiles
      pipenv-extra-chrootenv
    ];

    runScript = ''
      pipenv "$@"
    '';
  };

in

symlinkJoin {
  name = "pythonWithPipenv";
  version = "1.0";
  paths = [
    (myPythonDerivation.withPackages(myPythonPackages))
    pypi2nix
    ctags
    pipenvwrapper
    ];
  meta = with lib; {
    descripytion = "A python wrapper with pipenv and manylinux wheel support.";
    longDescription = ''A wrapper for python with a working pipenv and support for wheels (binary distribution of native libraries) with manylinux.
To override the used python derivation override the argument "myPythonDerivation". The default is the derivation named "python".
To add python packages to be installed override the argument "myPythonPackages".
This derivation is based on the blogpost https://sid-kap.github.io/index.html by Sidharth (Sid) Kapur.'';
    homepage = "https://github.com/neumantm/nur-packages";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}

