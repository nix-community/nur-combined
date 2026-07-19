{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  python3Packages,
  replaceVars,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mqttwarn";
  version = "0.36.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mqtt-tools";
    repo = "mqttwarn";
    tag = finalAttrs.version;
    hash =
      if stdenv.hostPlatform.isDarwin then
        "sha256-jdQNCmfGs1k52VKzcF132mmUSWkcdcsjx+AHxM+MRdw="
      else
        "sha256-mXz5xgqaqHDYl/wkxXnB9KElnpURhnTVIzG8xWWfOwQ=";
  };

  patches = [
    # Remove future package
    (fetchpatch {
      url = "https://github.com/mqtt-tools/mqttwarn/commit/4fc5d047c367c1047f58dab8c68cf447cc364563.patch";
      hash = "sha256-4z6vPg3gAm0sIFqa32EKFeaIfKSyNiPkm4EYcghY/qw=";
    })
    (replaceVars ./version.patch {
      inherit (finalAttrs) version;
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
    jinja2
    paho-mqtt
    requests
    simplejson
    six
  ];

  pythonRelaxDeps = true;

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
  ]
  ++ lib.flatten (lib.attrValues finalAttrs.passthru.optional-dependencies);

  meta = {
    description = "A highly configurable MQTT message router, where the routing targets are notification plugins";
    homepage = "https://guthub.com/mqtt-tools/mqttwarn";
    license = lib.licenses.epl20;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "mqttwarn";
  };
})
