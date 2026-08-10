{
  lib,
  pkgs,
  sources,
  python3,
  fetchPypi,
  makeWrapper,
}:
let
  cn2an = pkgs.python3Packages.buildPythonPackage {
    pname = "cn2an";
    version = "0.5.24";
    pyproject = true;
    src = fetchPypi {
      pname = "cn2an";
      version = "0.5.24";
      hash = "sha256-wnbPxLPJ51ghSEHeWXUC6xeN5QuNomM+00VWT5BwXw4=";
    };
    build-system = [ pkgs.python3Packages.setuptools ];
    dependencies = [ proces ];
    doCheck = false;
  };

  proces = pkgs.python3Packages.buildPythonPackage {
    pname = "proces";
    version = "0.1.7";
    pyproject = true;
    src = fetchPypi {
      pname = "proces";
      version = "0.1.7";
      hash = "sha256-cKBdnpc91oX3qQksWL5pWoGBpBHWN5bCEyMv0/3EN3U=";
    };
    build-system = [ pkgs.python3Packages.setuptools ];
    doCheck = false;
  };

  iso639 = pkgs.python3Packages.buildPythonPackage {
    pname = "iso639";
    version = "0.1.4";
    format = "setuptools";
    src = fetchPypi {
      pname = "iso639";
      version = "0.1.4";
      hash = "sha256-iLcM9sZO6cLClyKSgYyL6zLbnqb03h+EcamwgaPZLpg=";
    };
    doCheck = false;
  };

  bencodepy = pkgs.python3Packages.buildPythonPackage {
    pname = "bencodepy";
    version = "0.9.5";
    format = "setuptools";
    src = fetchPypi {
      pname = "bencodepy";
      version = "0.9.5";
      extension = "zip";
      hash = "sha256-r0chNNc+pY7as8LLLyz2HrnXg5CChMPS1bHP0434ZLg=";
    };
    doCheck = false;
  };

  pypushdeer = pkgs.python3Packages.buildPythonPackage {
    pname = "pypushdeer";
    version = "0.0.3";
    pyproject = true;
    src = fetchPypi {
      pname = "pypushdeer";
      version = "0.0.3";
      hash = "sha256-i441WVpFxMYkehl2H0ccnVtcjK1sW46AdsjKSG8pv/Y=";
    };
    build-system = [ pkgs.python3Packages.setuptools ];
    dependencies = [ pkgs.python3Packages.requests ];
    doCheck = false;
  };

  serverchan-sdk = pkgs.python3Packages.buildPythonPackage {
    pname = "serverchan-sdk";
    version = "1.0.6";
    pyproject = true;
    src = fetchPypi {
      pname = "serverchan_sdk";
      version = "1.0.6";
      hash = "sha256-p5qPCg1Lg9jKuuT2ygBDOOQE1Nu6nZ2TXyexU3nNUCs=";
    };
    build-system = [ pkgs.python3Packages.setuptools ];
    dependencies = [ pkgs.python3Packages.requests ];
    doCheck = false;
  };

  opencc-python-reimplemented = pkgs.python3Packages.buildPythonPackage {
    pname = "opencc-python-reimplemented";
    version = "0.1.7";
    pyproject = true;
    src = fetchPypi {
      pname = "opencc-python-reimplemented";
      version = "0.1.7";
      hash = "sha256-T3d+o0YaJSV6e4dhEs+pC7asq8bfuEO/TREmbkNXne4=";
    };
    build-system = [ pkgs.python3Packages.setuptools ];
    doCheck = false;
  };

  fast-bencode-src = fetchPypi {
    pname = "fast_bencode";
    version = "1.1.8";
    hash = "sha256-PHhRcaowoMpnp/JVCNXN+GNrwQk9IbwfJ8LdSS17/LE=";
  };

  slackBolt = pkgs.python3Packages.slack-bolt.overridePythonAttrs (old: {
    doCheck = false;
  });

  fast-bencode = pkgs.python3Packages.buildPythonPackage {
    pname = "fast-bencode";
    version = "1.1.8";
    pyproject = true;
    src = fast-bencode-src;
    build-system = with pkgs.python3Packages; [
      setuptools
      cython
    ];
    doCheck = false;
  };
in
pkgs.python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nexus-media";
  inherit (sources.nexus-media) version src;
  pyproject = true;

  build-system = [
    pkgs.python3Packages.setuptools
    pkgs.python3Packages.wheel
  ];

  propagatedBuildInputs = with pkgs.python3Packages; [
    alembic
    anitopy
    apscheduler
    beautifulsoup4
    bencodepy
    boto3
    cn2an
    cryptography
    dateparser
    defusedxml
    fast-bencode
    fastapi
    filelock
    google-genai
    granian
    h2
    httpx
    iso639
    jinja2
    jsonpath
    loguru
    lxml
    ollama
    openai
    opencc-python-reimplemented
    orjson
    parse
    pillow
    plexapi
    psutil
    psycopg2-binary
    pwdlib
    pydantic-ai-slim
    pydantic-settings
    pyjwt
    pymysql
    pyquery
    pypushdeer
    python-dateutil
    python-hosts
    python-multipart
    qbittorrent-api
    redis
    ruamel-yaml
    ruff
    scalar-fastapi
    serverchan-sdk
    setuptools
    slackBolt
    smbprotocol
    socksio
    sqlalchemy
    srt
    tenacity
    transmission-rpc
    urllib3
    uvloop
    watchdog
    watchfiles
    webdav4
    websockets
    wheel
  ];

  nativeBuildInputs = [ makeWrapper ];

  dontWrapPythonPrograms = true;
  dontCheckRuntimeDeps = true;

  env.PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";

  postInstall = ''
    mkdir -p $out/bin $out/libexec/nexus-media $out/share/nexus-media
    cp ${finalAttrs.src}/run.py $out/libexec/nexus-media/run.py
    cp -r ${finalAttrs.src}/. $out/share/nexus-media/
    makeWrapper ${python3.interpreter} $out/bin/nexus-media \
      --chdir $out/libexec/nexus-media \
      --run 'if [ -z "''${NEXUS_MEDIA_DATA:-}" ]; then export NEXUS_MEDIA_DATA="''${XDG_DATA_HOME:-$HOME/.local/share}/nexus-media"; fi; export NEXUS_MEDIA_CONFIG="''$NEXUS_MEDIA_DATA/config.yaml"; mkdir -p "''$NEXUS_MEDIA_DATA"' \
      --set PROJECT_ROOT "$out/share/nexus-media" \
      --prefix PYTHONPATH : "$out/${python3.sitePackages}" \
      --add-flags "$out/libexec/nexus-media/run.py"
  '';

  meta = {
    changelog = "https://github.com/linyuan0213/nexus-media/releases/tag/v${finalAttrs.version}";
    description = "Media library manager with automated downloading, media organization and subscription workflows";
    homepage = "https://github.com/linyuan0213/nexus-media";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
    mainProgram = "nexus-media";
  };
})
