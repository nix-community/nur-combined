# restore python2 before https://github.com/NixOS/nixpkgs/pull/479971
pythonPackages: pythonPackagesSuper:
let
  inherit (pythonPackages) callPackage;
  toPythonModule =
    drv:
    drv
    // {
      pythonModule = pythonPackages.python;
      pythonPath = [ ];
      requiredPythonModules = pythonPackages.requiredPythonModules drv.propagatedBuildInputs;
      passthru = (drv.passthru or { }) // {
        pythonModule = pythonPackages.python;
        pythonPath = [ ];
        requiredPythonModules = pythonPackages.requiredPythonModules drv.propagatedBuildInputs;
      };
    };
in
{
  isPy27 = true;
  isPy2 = true;
  isPy37 = false;

  buildPythonPackage = callPackage ./buildPythonPackage {
    buildPythonPackageSuper = import ./mk-python-derivation.nix {
      inherit (pythonPackages)
        lib
        python
        stdenv
        wrapPython
        setuptools
        pipBuildHook
        pipInstallHook
        pythonCatchConflictsHook
        pythonImportsCheckHook
        pythonOutputDistHook
        pythonRemoveBinBytecodeHook
        pythonRemoveTestsDirHook
        setuptoolsBuildHook
        wheelUnpackHook
        eggUnpackHook
        eggBuildHook
        eggInstallHook
        ;
      inherit (pythonPackages.pkgs)
        config
        ensureNewerSourcesForZipFilesHook
        unzip
        update-python-libraries
        ;
      inherit toPythonModule;
      namePrefix = "${pythonPackages.python.libPrefix}-";
    };
  };

  alabaster = callPackage ./alabaster { };

  apipkg = callPackage ./apipkg { };

  attrs = callPackage ./attrs { };

  babel = callPackage ./babel { };

  backports-functools-lru-cache = callPackage ./backports-functools-lru-cache { };

  backports-zoneinfo = callPackage ./backports-zoneinfo { };

  boto3 = callPackage ./boto3 { };

  botocore = callPackage ./botocore { };

  brotli = callPackage ./brotli { };

  cached-property = callPackage ./cached-property { };

  calver = callPackage ./calver { };

  certifi = callPackage ./certifi { };

  chardet = callPackage ./chardet { };

  charset-normalizer = callPackage ./charset-normalizer { };

  cheetah = callPackage ./cheetah { };

  cffi = callPackage ./cffi { };

  click = callPackage ./click { };

  configparser = callPackage ./configparser { };

  construct = callPackage ./construct { };

  contextlib2 = callPackage ./contextlib2 { };

  coverage = callPackage ./coverage { };

  cryptography = callPackage ./cryptography { };

  cryptography-vectors = callPackage ./cryptography-vectors { };

  cython = callPackage ./cython { };

  decorator = callPackage ./decorator { };

  defusedxml = callPackage ./defusedxml { };

  docutils = callPackage ./docutils { };

  ecdsa = callPackage ./ecdsa { };

  enum = callPackage ./enum { };

  enum34 = callPackage ./enum34 { };

  execnet = callPackage ./execnet { };

  filelock = callPackage ./filelock { };

  flaky = callPackage ./flaky { };

  flask = callPackage ./flask { };

  flit-core = callPackage ./flit-core { };

  freezegun = callPackage ./freezegun { };

  futures = callPackage ./futures { };

  google-apputils = callPackage ./google-apputils { };

  greenlet = callPackage ./greenlet { };

  html5lib = callPackage ./html5lib { };

  httpretty = callPackage ./httpretty { };

  hypothesis = callPackage ./hypothesis { };

  idna = callPackage ./idna { };

  importlib-metadata = callPackage ./importlib-metadata { };

  intreehooks = callPackage ./intreehooks { };

  ipaddr = callPackage ./ipaddr { };

  ipaddress = callPackage ./ipaddress { };

  iso8601 = callPackage ./iso8601 { };

  itsdangerous = callPackage ./itsdangerous { };

  jaraco-classes = callPackage ./jaraco-classes { };

  jinja2 = callPackage ./jinja2 { };

  libcloud = callPackage ./libcloud { };

  lpod = callPackage ./lpod { };

  marisa = callPackage ./marisa {
    inherit (pythonPackages.pkgs) marisa;
  };

  markdown = callPackage ./markdown { };

  markupsafe = callPackage ./markupsafe { };

  mock = callPackage ./mock { };

  more-itertools = callPackage ./more-itertools { };

  mutagen = callPackage ./mutagen { };

  nose = callPackage ./nose { };

  numpy = callPackage ./numpy { };

  packaging = callPackage ./packaging { };

  pathlib2 = callPackage ./pathlib2 { };

  pathspec = callPackage ./pathspec { };

  pefile = callPackage ./pefile { };

  pillow = callPackage ./pillow { };

  pip = callPackage ./pip { };

  pluggy = callPackage ./pluggy { };

  poetry-core = callPackage ./poetry-core { };

  prettytable = callPackage ./prettytable { };

  protobuf = callPackage ./protobuf {
    disabled = pythonPackages.isPyPy;
    protobuf = pythonPackages.pkgs.protobuf; # last version compatible with Python 2
  };

  psutil = callPackage ./psutil { };

  pyasn1 = callPackage ./pyasn1 { };

  pycairo = callPackage ./pycairo {
    inherit (pythonPackages.pkgs.buildPackages) meson;
  };

  pycparser = callPackage ./pycparser { };

  pygame-sdl2 = callPackage ./pygame-sdl2 { };

  pygments = callPackage ./pygments { };

  pygobject3 = callPackage ./pygobject {
    inherit (pythonPackages.pkgs) meson;
  };

  pygtk = callPackage ./pygtk { };

  pyGtkGlade = pythonPackages.pygtk.override {
    inherit (pythonPackages.pkgs.gnome2) libglade;
  };

  pyjwt = callPackage ./pyjwt { };

  pyopenssl = callPackage ./pyopenssl { };

  pyparsing = callPackage ./pyparsing { };

  pyroma = callPackage ./pyroma { };

  pysqlite = callPackage ./pysqlite { };

  pytest = pythonPackages.pytest_4;

  pytest_4 = callPackage ./pytest { };

  pytest-expect = callPackage ./pytest-expect { };

  pytest-forked = callPackage ./pytest-forked { };

  pytest-mock = callPackage ./pytest-mock { };

  pytest-runner = callPackage ./pytest-runner { };

  pytest-xdist = callPackage ./pytest-xdist { };

  python-dateutil = callPackage ./python-dateutil { };

  pytoml = callPackage ./pytoml { };

  pyyaml = callPackage ./pyyaml { };

  qpid-python = callPackage ./qpid-python { };

  readthedocs-sphinx-ext = callPackage ./readthedocs-sphinx-ext { };

  requests = callPackage ./requests { };

  s3transfer = callPackage ./s3transfer { };

  scandir = callPackage ./scandir { };

  #sequoia = disabled super.sequoia;

  setuptools = callPackage ./setuptools { };

  setuptools-scm = callPackage ./setuptools-scm { };

  six = callPackage ./six { };

  snowballstemmer = callPackage ./snowballstemmer { };

  sphinx = callPackage ./sphinx { };

  sphinx-rtd-theme = callPackage ./sphinx-rtd-theme { };

  sphinxcontrib-jquery = callPackage ./sphinxcontrib-jquery { };

  sphinxcontrib-websupport = callPackage ./sphinxcontrib-websupport { };

  sqlalchemy = callPackage ./sqlalchemy { };

  time-machine = callPackage ./time-machine { };

  TurboCheetah = callPackage ./TurboCheetah { };

  typing = callPackage ./typing { };

  typing-extensions = callPackage ./typing-extensions { };

  unittest2 = callPackage ./unittest2 { };

  urllib3 = callPackage ./urllib3 { };

  wcwidth = callPackage ./wcwidth { };

  werkzeug = callPackage ./werkzeug { };

  wxPython30 = callPackage ./wxPython {
    wxGTK = pythonPackages.pkgs.wxGTK30;
  };

  wxPython = pythonPackages.wxPython30;

  vcrpy = callPackage ./vcrpy { };

  virtualenv = callPackage ./virtualenv { };

  yenc = callPackage ./yenc { };

  yt = callPackage ./yt { };

  #zeek = disabled super.zeek;

  zipp = callPackage ./zipp { };

  zope-interface = callPackage ./zope-interface { };
}
