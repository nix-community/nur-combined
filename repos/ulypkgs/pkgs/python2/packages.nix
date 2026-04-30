# restore python2 before https://github.com/NixOS/nixpkgs/pull/479971
pythonPackages: pythonPackagesSuper:
let
  inherit (pythonPackages) callPackage;
in
{
  buildPythonPackage = callPackage ./buildPythonPackage {
    buildPythonPackageSuper = pythonPackagesSuper.buildPythonPackage;
  };

  alabaster = callPackage ./alabaster { };

  apipkg = callPackage ./apipkg { };

  attrs = callPackage ./attrs { };

  babel = callPackage ./babel { };

  backports-functools-lru-cache = callPackage ./backports-functools-lru-cache { };

  backports-zoneinfo = callPackage ./backports-zoneinfo { };

  boto3 = callPackage ./boto3/1_17.nix { };

  botocore = callPackage ./botocore/1_20.nix { };

  brotli = callPackage ./brotli { };

  cached-property = callPackage ./cached-property { };

  calver = callPackage ./calver { };

  certifi = callPackage ./certifi/python2.nix { certifi = pythonPackagesSuper.certifi; };

  chardet = callPackage ./chardet/2.nix { };

  charset-normalizer = callPackage ./charset-normalizer { };

  cheetah = callPackage ./cheetah { };

  cffi = callPackage ./cffi { };

  click = callPackage ./click/7.nix { };

  configparser = callPackage ./configparser/4.nix { };

  construct = callPackage ./construct/2.10.54.nix { };

  contextlib2 = callPackage ./contextlib2/0.nix { };

  coverage = callPackage ./coverage { };

  cryptography = callPackage ./cryptography/3.3.nix { };

  cryptography-vectors = callPackage ./cryptography-vectors { };

  cython = callPackage ./cython { };

  decorator = callPackage ./decorator/4.nix { };

  defusedxml = callPackage ./defusedxml { };

  docutils = callPackage ./docutils { };

  enum = callPackage ./enum { };

  enum34 = callPackage ./enum34 { };

  execnet = callPackage ./execnet { };

  filelock = callPackage ./filelock/3.2.nix { };

  flaky = callPackage ./flaky { };

  flask = callPackage ./flask/1.nix { };

  flit-core = callPackage ./flit-core { };

  freezegun = callPackage ./freezegun/0.3.nix { };

  futures = callPackage ./futures { };

  google-apputils = callPackage ./google-apputils { };

  greenlet = callPackage ./greenlet { };

  html5lib = callPackage ./html5lib { };

  httpretty = callPackage ./httpretty/0.nix { };

  hypothesis = callPackage ./hypothesis/2.nix { };

  idna = callPackage ./idna/2.nix { };

  importlib-metadata = callPackage ./importlib-metadata { };

  intreehooks = callPackage ./intreehooks { };

  ipaddr = callPackage ./ipaddr { };

  ipaddress = callPackage ./ipaddress { };

  iso8601 = callPackage ./iso8601 { };

  itsdangerous = callPackage ./itsdangerous/1.nix { };

  jaraco-classes = callPackage ./jaraco-classes { };

  jinja2 = callPackage ./jinja2/2.nix { };

  libcloud = callPackage ./libcloud/2.nix { };

  lpod = callPackage ./lpod { };

  marisa = callPackage ./marisa {
    inherit (pythonPackagesSuper) marisa;
  };

  markdown = callPackage ./markdown/3_1.nix { };

  markupsafe = callPackage ./markupsafe/1.nix { };

  mock = callPackage ./mock/2.nix { };

  more-itertools = callPackage ./more-itertools { };

  mutagen = callPackage ./mutagen/1.43.nix { };

  nose = callPackage ./nose { };

  numpy = callPackage ./numpy/1.16.nix { };

  packaging = callPackage ./packaging/2.nix { };

  pathlib2 = callPackage ./pathlib2 { };

  pathspec = callPackage ./pathspec { };

  pefile = callPackage ./pefile { };

  pillow = callPackage ./pillow { };

  pip = callPackage ./pip/20.nix { };

  pluggy = callPackage ./pluggy/0.nix { };

  poetry-core = callPackage ./poetry-core { };

  prettytable = callPackage ./prettytable/1.nix { };

  protobuf = callPackage ./protobuf {
    disabled = pythonPackages.isPyPy;
    protobuf = pythonPackagesSuper.protobuf3_17; # last version compatible with Python 2
  };

  psutil = callPackage ./psutil { };

  pyasn1 = callPackage ./pyasn1 { };

  pycairo = callPackage ./pycairo/1.18.nix {
    inherit (pythonPackagesSuper.buildPackages) meson;
  };

  pycparser = callPackage ./pycparser { };

  pygame-sdl2 = callPackage ./pygame-sdl2 { };

  pygments = callPackage ./pygments { };

  pygobject3 = callPackage ./pygobject/3.36.nix {
    inherit (pythonPackagesSuper) meson;
  };

  pygtk = callPackage ./pygtk { };

  pyGtkGlade = pythonPackages.pygtk.override {
    inherit (pythonPackagesSuper.gnome2) libglade;
  };

  pyjwt = callPackage ./pyjwt/1.nix { };

  pyopenssl = callPackage ./pyopenssl { };

  pyparsing = callPackage ./pyparsing { };

  pyroma = callPackage ./pyroma/2.nix { };

  pysqlite = callPackage ./pysqlite { };

  pytest = pythonPackages.pytest_4;

  pytest_4 = callPackage ./pytest/4.nix { };

  pytest-expect = callPackage ./pytest-expect { };

  pytest-forked = callPackage ./pytest-forked { };

  pytest-mock = callPackage ./pytest-mock { };

  pytest-runner = callPackage ./pytest-runner/2.nix { };

  pytest-xdist = callPackage ./pytest-xdist { };

  python-dateutil = callPackage ./python-dateutil { };

  pytoml = callPackage ./pytoml { };

  pyyaml = callPackage ./pyyaml/5.nix { };

  qpid-python = callPackage ./qpid-python { };

  readthedocs-sphinx-ext = callPackage ./readthedocs-sphinx-ext { };

  requests = callPackage ./requests { };

  s3transfer = callPackage ./s3transfer/0_4.nix { };

  scandir = callPackage ./scandir { };

  #sequoia = disabled super.sequoia;

  setuptools = callPackage ./setuptools/44.0.nix { };

  setuptools-scm = callPackage ./setuptools-scm/2.nix { };

  six = callPackage ./six { };

  snowballstemmer = callPackage ./snowballstemmer { };

  sphinx = callPackage ./sphinx/2.nix { };

  sphinx-rtd-theme = callPackage ./sphinx-rtd-theme { };

  sphinxcontrib-jquery = callPackage ./sphinxcontrib-jquery { };

  sphinxcontrib-websupport = callPackage ./sphinxcontrib-websupport { };

  sqlalchemy = callPackage ./sqlalchemy { };

  time-machine = callPackage ./time-machine { };

  TurboCheetah = callPackage ./TurboCheetah { };

  typing = callPackage ./typing { };

  typing-extensions = callPackage ./typing-extensions { };

  unittest2 = callPackage ./unittest2 { };

  urllib3 = callPackage ./urllib3/2.nix { };

  wcwidth = callPackage ./wcwidth { };

  werkzeug = callPackage ./werkzeug/1.nix { };

  wxPython30 = callPackage ./wxPython/3.0.nix {
    wxGTK = pythonPackagesSuper.wxGTK30;
  };

  wxPython = pythonPackages.wxPython30;

  vcrpy = callPackage ./vcrpy/3.nix { };

  virtualenv = callPackage ./virtualenv { };

  yenc = callPackage ./yenc { };

  yt = callPackage ./yt { };

  #zeek = disabled super.zeek;

  zipp = callPackage ./zipp/1.nix { };

  zope-interface = callPackage ./zope-interface { };
}
