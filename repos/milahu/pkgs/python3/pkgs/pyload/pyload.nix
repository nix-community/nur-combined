# based on https://github.com/NixOS/nixpkgs/commit/c0914a76c40230fb06eb6df8f54995796edef3ef
# Date:   Sun Mar 21 03:18:15 2021 +0100

# usage:
# webinterface http://localhost:8000/
# user: pyload
# password: pyload

{ lib
, fetchFromGitHub
, fetchpatch
, python3
, gocr
, unrar
, rhino
, spidermonkey
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pyload";

  # versions https://github.com/pyload/pyload/issues/4339
  version = "0.5.0b3.dev72";

  src = fetchFromGitHub {
    owner = "pyload";
    repo = "pyload";
    rev = "af9c80f392b4cf90b1e37f7d4b28ca3705327e81";
    sha256 = "sha256-0E/curwky6BEbQEJj+99dQRDRS90qOgIkJqxq/vUCh4=";
  };

  # relax versions
  postPatch = ''
    sed -i -E 's/([a-zA-Z0-9_-]+)~=/\1>=/' setup.cfg
  '';

  # TODO add more deps, so we can use more features
  # https://github.com/pyload/pyload/blob/main/setup.cfg
  buildInputs = [
    unrar # unfree
    rhino
    spidermonkey
    gocr
  ] ++ (with python3.pkgs; [
    paver
  ]);

  propagatedBuildInputs = with python3.pkgs; [
    pycurl
    jinja2
    # fix: error: Package ‘python3.10-Beaker-1.11.0’ in /nix/store/qb3dg4cx5jzk3pa8szzi0ziwnqy33p50-source/pkgs/development/python-modules/beaker/default.nix:72 is marked as insecure, refusing to evaluate.
    # also, beaker is not needed any more
    # also, beaker depends on pycryptopp, which is broken for python3.10 (last binary release for python3.9)
    #beaker
    thrift
    simplejson
    pycrypto
    feedparser
    tkinter
    beautifulsoup4
    send2trash
    js2py
    # FIXME: ERROR: Could not find a version that satisfies the requirement Flask>=2.3.0; python_version >= "3.8"
    # pkgs.python3.pkgs.flask.version = "2.2.5"
    # https://github.com/NixOS/nixpkgs/pull/245320 # python3.pkgs.flask: 2.2.5 -> 2.3.2
    flask
    flask-compress
    flask-caching
    flask-themes2
    filetype
    semver
    cheroot
    cryptography
    flask-babel
    flask-session
    flask-session2
    bitmath
    setuptools # pkg_resources https://github.com/pyload/pyload/issues/4143
    certifi
  ];

  doCheck = false; # FIXME?

  meta = with lib; {
    description = "Free and open source downloader for 1-click-hosting sites";
    homepage = "https://github.com/pyload/pyload";
    license = licenses.gpl3;
    #maintainers = with maintainers; [];
    platforms = platforms.all;
  };
}
