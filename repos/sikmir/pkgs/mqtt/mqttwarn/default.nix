{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  substituteAll,
}:

python3Packages.buildPythonApplication rec {
  pname = "mqttwarn";
  version = "0.35.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mqtt-tools";
    repo = "mqttwarn";
    tag = version;
    hash = "sha256-jdQNCmfGs1k52VKzcF132mmUSWkcdcsjx+AHxM+MRdw=";
  };

  patches = [
    (substituteAll {
      src = ./version.patch;
      inherit version;
    })
  ];

  build-system = with python3Packages; [
    setuptools
    versioningit
  ];

  dependencies = with python3Packages; [
    attrs
    docopt
    funcy
    future
    jinja2
    paho-mqtt
    requests
    six
  ];

  pythonRelaxDeps = [
    "attrs"
    "future"
    "paho-mqtt"
  ];

  optional-dependencies = with python3Packages; {
    apprise = [ apprise ];
    celery = [ celery ];
    chromecast = [ pychromecast ];
    dnsupdate = [ dnspython ];
    serial = [ pyserial ];
    ssh = [ paramiko ];
    tootpaste = [ mastodon-py ];
    websocket = [ websocket-client ];
  };

  doCheck = false;

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
  ] ++ lib.flatten (lib.attrValues optional-dependencies);

  meta = {
    description = "A highly configurable MQTT message router, where the routing targets are notification plugins";
    homepage = "https://guthub.com/mqtt-tools/mqttwarn";
    license = lib.licenses.epl20;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "mqttwarn";
  };
}
