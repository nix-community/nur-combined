{
  lib,
  stdenv,
  fetchFromGitHub,
  python312Packages,
  replaceVars,
}:

let
  python3Packages = python312Packages;
in
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mqttwarn";
  version = "0.35.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mqtt-tools";
    repo = "mqttwarn";
    tag = finalAttrs.version;
    hash =
      if stdenv.hostPlatform.isDarwin then
        "sha256-jdQNCmfGs1k52VKzcF132mmUSWkcdcsjx+AHxM+MRdw="
      else
        "sha256-lr1cJvfQtkSc/DQc0fagAn5LQBgfVIwlUfxdbogcofM=";
  };

  patches = [
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
    future
    jinja2
    paho-mqtt
    requests
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
