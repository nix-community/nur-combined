{
  lib,
  fetchFromGitHub,
  nix-update-script,
  callPackage,
  python3Packages,
}:
let
  pythonPackages = python3Packages // {
    lxml =
      if lib.versionAtLeast python3Packages.lxml.version "6.1.3" then
        python3Packages.lxml
      else
        python3Packages.lxml.overridePythonAttrs {
          version = "6.1.3";
          src = fetchFromGitHub {
            owner = "lxml";
            repo = "lxml";
            tag = "lxml-6.1.3";
            hash = "sha256-ye0qwrcfMINdVCg8EvcoQ+NAnWvF3JSJfjJ2Zupnmc8=";
          };
        };
    lxml-html-clean = python3Packages.lxml-html-clean.override { inherit (pythonPackages) lxml; };
    html-text = python3Packages.html-text.override { inherit (pythonPackages) lxml lxml-html-clean; };
    extruct = python3Packages.extruct.override { inherit (pythonPackages) lxml html-text; };
    feedgen = python3Packages.feedgen.override { inherit (pythonPackages) lxml; };
    inscriptis = python3Packages.inscriptis.override { inherit (pythonPackages) lxml; };
    blobfile = python3Packages.blobfile.override { inherit (pythonPackages) lxml; };
    tiktoken = python3Packages.tiktoken.override { inherit (pythonPackages) blobfile; };
    litellm = python3Packages.litellm.override { inherit (pythonPackages) tiktoken; };
  };
in
pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "changedetection-io";
  version = "0.60.9";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "dgtlmoon";
    repo = "changedetection.io";
    tag = finalAttrs.version;
    hash = "sha256-E7ujQNMG1Qs6NAocAOYP8My8PDfFrI1ejoEIJfvC5VQ=";
  };

  build-system = [ pythonPackages.setuptools ];

  pythonRelaxDeps = [
    "apprise"
    "beautifulsoup4"
    "chardet"
    "cryptography"
    "elementpath"
    "flask_wtf"
    "greenlet"
    "jsonpath-ng"
    "orjson"
    "pydantic"
    "pyppeteer-ng"
    "python-engineio"
    "selenium"
    "werkzeug"
  ];

  pythonRemoveDeps = [
    "pyppeteerstealth"
    "pytest"
    "pytest-flask"
    "pytest-mock"
    "pytest-xdist"
  ];

  dependencies =
    with pythonPackages;
    [
      apprise
      arrow
      babel
      beautifulsoup4
      blinker
      brotli
      chardet
      cryptography
      diff-match-patch
      elementpath
      extruct
      feedgen
      feedparser
      flask
      flask-babel
      flask-compress
      flask-cors
      flask-login
      flask-paginate
      flask-restful
      flask-socketio
      flask-wtf
      gevent
      greenlet
      inscriptis
      jinja2
      jq
      jsonpath-ng
      jsonschema
      linkify-it-py
      litellm
      loguru
      lxml
      openapi-core
      openpyxl
      orjson
      paho-mqtt
      panzi-json-logic
      playwright
      pluggy
      price-parser
      psutil
      puremagic
      pydantic
      pyppeteer-ng
      python-engineio
      python-socketio
      pytz
      rank-bm25
      rapidfuzz
      referencing
      requests
      requests-file
      segno
      selenium
      timeago
      tzdata
      validators
      werkzeug
      wtforms
    ]
    ++ requests.optional-dependencies.socks
    ++ openapi-core.optional-dependencies.flask;

  doCheck = false;

  pythonImportsCheck = [
    "changedetectionio"
    "changedetectionio.flask_app"
    "changedetectionio.model.LLMSettings"
  ];

  passthru = {
    updateScript = nix-update-script {
      attrPath = "changedetection-io";
      extraArgs = [
        "-f"
        "."
        "--use-github-releases"
      ];
    };
    tests.packaging = callPackage ../../tests/pkgs/changedetection-io.nix {
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Self-hosted website change monitoring and notifications";
    homepage = "https://github.com/dgtlmoon/changedetection.io";
    changelog = "https://github.com/dgtlmoon/changedetection.io/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    mainProgram = "changedetection.io";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
})
