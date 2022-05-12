/*
nix-build -E 'with import <nixpkgs> {}; callPackage ./pyload.nix {}'
*/

# based on https://github.com/NixOS/nixpkgs/commit/c0914a76c40230fb06eb6df8f54995796edef3ef
# Date:   Sun Mar 21 03:18:15 2021 +0100

{ lib
, fetchFromGitHub
, fetchpatch
, python3Packages
, gocr
, unrar
, rhino
, spidermonkey
}:

let
  pyjsparser = python3Packages.buildPythonPackage rec {
    pname = "pyjsparser";
    version = "2.7.1";
    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-vmDaa3eMxaUpamnY59YU8fhw+vlOGxtqxZHyrV1ylXk=";
    };
    checkInputs = with python3Packages; [
    ];
    meta = with lib; {
      homepage = "https://github.com/PiotrDabkowski/pyjsparser";
      description = "Fast javascript parser (based on esprima.js)";
      license = licenses.mit;
    };
  };

  js2py = python3Packages.buildPythonPackage rec {
    pname = "js2py";
    version = "0.71";
    # build from source hangs
    /*
    src = python3Packages.fetchPypi {
      pname = "Js2Py";
      inherit version;
      sha256 = "sha256-pBsQCd0UmK59Q2v6WslSoIypKku54x3Kbou5ZrSff84=";
    };
    */
    format = "wheel";
    src = python3Packages.fetchPypi rec {
      pname = "Js2Py";
      inherit version format;
      sha256 = "sha256-fz36MMS446w+3WTDYclQqMJYejCoaFSuuMH/tvTdJLQ=";
      dist = python;
      python = "py3";
    };

    # fix: SyntaxWarning: "is" with a literal
    # https://github.com/PiotrDabkowski/Js2Py/pull/284
    #postPatch = ''
    #  sed -i "s/ or g is 'OP_CODE':$/ or g == 'OP_CODE':/" js2py/internals/opcodes.py
    #'';

    buildInputs = (with python3Packages; [
      six
    ]);
    propagatedBuildInputs = (with python3Packages; [
      pyjsparser
      tzlocal
    ]);
    checkInputs = with python3Packages; [
    ];
    meta = with lib; {
      homepage = "https://github.com/PiotrDabkowski/Js2Py";
      description = "JavaScript to Python Translator & JavaScript interpreter written in 100% pure Python";
      license = licenses.mit;
    };
  };

  flask-themes2 = python3Packages.buildPythonPackage rec {
    pname = "flask-themes2";
    version = "1.0.0";
    src = python3Packages.fetchPypi rec {
      pname = "Flask-Themes2";
      inherit version;
      sha256 = "sha256-0U0cSdBddb9+IG3CU6zUPlxaJhQlxOV6OLgxnNDChy8=";
    };
    buildInputs = (with python3Packages; [
      flask
    ]);
    checkPhase = ''
      runHook preCheck
      python -m unittest
      runHook postCheck
    '';
    checkInputs = with python3Packages; [
    ];
    meta = with lib; {
      homepage = "https://github.com/sysr-q/flask-themes2";
      description = "Provides infrastructure for theming Flask applications";
      license = licenses.mit;
    };
  };

in python3Packages.buildPythonApplication rec {
  pname = "pyload";

  # usage:
  # webinterface http://localhost:8000/ -> user: pyload + password: pyload

  /*
  version = "unstable-2022-05-06";
  src = fetchFromGitHub {
    owner = "pyload";
    repo = "pyload";
    rev = "690f583b770076640924799ce48ecfba43c27b9e";
    sha256 = "sha256-UwZQ/DYXIyvpgm5lRIYwkmHjlsbqCdU5xkqd9iG5glE=";
  };
  */

  version = "0.5.0b3.dev18";
  src = python3Packages.fetchPypi rec {
    pname = "pyload-ng";
    inherit version;
    sha256 = "sha256-VenQdxPIGZ5jAQWoTUYDZATngSGvfiedsOLOBuYpQ+o=";
  };

  /*
  # ERROR: Could not find a version that satisfies the requirement cryptography~=3.0
  version = "0.5.0b3.dev18";
  format = "wheel";
  src = python3Packages.fetchPypi rec {
    pname = "pyload_ng";
    inherit version format;
    sha256 = "sha256-Ytw1JNTmBnZi64L2Biwcdw+Z779ttMMDkgQboZKM8KY=";
    dist = python;
    python = "py3";
  };
  */

  # relax versions
  # fix: Could not find a version that satisfies the requirement cryptography~=3.0
  # https://github.com/pyload/pyload/issues/4144
  postPatch = ''
    sed -i 's/cryptography~=3.0/cryptography>=3.0/' setup.cfg
    sed -i 's/Flask-Babel~=1.0/Flask-Babel>=1.0/' setup.cfg
  '';

  # TODO add more deps, so we can use more features
  # https://github.com/pyload/pyload/blob/main/setup.cfg
  buildInputs = [
    unrar
    rhino
    spidermonkey
    gocr
  ] ++ (with python3Packages; [
    paver
  ]);
  propagatedBuildInputs = with python3Packages; [
    pycurl
    jinja2
    beaker
    thrift
    simplejson
    pycrypto
    feedparser
    tkinter
    beautifulsoup4
    send2trash
    js2py
    flask-compress
    flask-caching
    flask-themes2
    filetype
    semver
    cheroot
    cryptography
    flask-babel
    flask-session
    bitmath
    setuptools # pkg_resources https://github.com/pyload/pyload/issues/4143
  ];

  doCheck = false;

  meta = with lib; {
    description = "Free and open source downloader for 1-click-hosting sites";
    homepage = "https://github.com/pyload/pyload";
    license = licenses.gpl3;
    #maintainers = with maintainers; [];
    platforms = platforms.all;
  };
}
