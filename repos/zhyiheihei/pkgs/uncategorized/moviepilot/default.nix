{
  lib,
  pkgs,
  stdenv,
  sources,
  makeWrapper,
  nodejs,
  fetchNpmDeps,
  npmHooks,
  unzip,
  python3Packages,
}:
let
  version = sources.moviepilot.version;
  src = sources.moviepilot.src;
  slackBolt = pkgs.python3Packages.slack-bolt.overridePythonAttrs (old: {
    doCheck = false;
  });

  frontendDist = stdenv.mkDerivation {
    pname = "moviepilot-frontend";
    inherit (sources."moviepilot-frontend") version src;

    nativeBuildInputs = [ unzip ];
    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      unzip -q $src -d $out
      if [ -d "$out/dist" ]; then
        mv $out/dist/* $out/
        rmdir $out/dist
      fi
      runHook postInstall
    '';
  };

  frontendRuntime = stdenv.mkDerivation (finalAttrs: {
    pname = "moviepilot-frontend-runtime";
    version = sources."moviepilot-frontend".version;

    src = ./frontend-runtime;

    npmDeps = fetchNpmDeps {
      inherit (finalAttrs) src;
      hash = "sha256-wIlCxaFULYP9uE0VxELIFBSL2dnxbLGy9e5tYRkUrbA=";
    };

    nativeBuildInputs = [
      nodejs
      npmHooks.npmConfigHook
    ];

    env.npm_config_registry = "https://registry.npmmirror.com";

    buildPhase = ''
      runHook preBuild
      npm install
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/moviepilot
      cp -r node_modules $out/libexec/moviepilot/node_modules
      cp package.json $out/libexec/moviepilot/package.json
      cp ${./service.js} $out/libexec/moviepilot/service.js
      runHook postInstall
    '';
  });

  resourcesDir = stdenv.mkDerivation {
    pname = "moviepilot-resources";
    inherit (sources."moviepilot-resources") version;
    inherit (sources."moviepilot-resources") src;

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -rL resources.v2/. $out/
      runHook postInstall
    '';
  };
in
pkgs.python3Packages.buildPythonPackage rec {
  pname = "moviepilot";
  inherit version src;
  pyproject = false;

  postPatch = ''
    sed -i '/^import pillow_avif/d' app/api/endpoints/system.py app/chain/recommend.py
  '';

  dontBuild = true;
  dontConfigure = true;
  doCheck = false;

  env.PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  propagatedBuildInputs =
    (with pkgs.python3Packages; [
      aiofiles
      aiosqlite
      alembic
      anitopy
      anthropic
      anyio
      apscheduler
      asyncpg
      bcrypt
      beautifulsoup4
      boto3
      cachetools
      chardet
      click
      cryptography
      dateparser
      ddgs
      discordpy
      docker
      fastapi
      fastbencode
      google-genai
      h2
      httpx
      jinja2
      langchain
      langchain-anthropic
      langchain-aws
      langchain-community
      langchain-core
      langchain-deepseek
      langchain-google-genai
      langchain-openai
      langgraph
      lark-oapi
      lxml
      openai
      oss2
      packaging
      parse
      passlib
      pillow
      plexapi
      psutil
      psycopg2-binary
      pycryptodome
      pydantic
      pydantic-settings
      pyjwt
      pympler
      pyopenssl
      pyotp
      pyparsing
      pyquery
      pysocks
      pystray
      pytelegrambotapi
      pyvirtualdisplay
      python-multipart
      pywebpush
      pyyaml
      qbittorrent-api
      redis
      regex
      requests
      rsa
      ruamel-yaml
      setproctitle
      setuptools
      slackBolt
      slack-sdk
      smbprotocol
      socksio
      sqlalchemy
      starlette
      tqdm
      transmission-rpc
      urllib3
      uvicorn
      watchfiles
      watchdog
      webauthn
      websocket-client
    ])
    ++ [
      python3Packages.aioshutil
      python3Packages.cn2an
      python3Packages.jieba-next
      python3Packages.pinyin2hanzi
      python3Packages.proces
      python3Packages.telegramify-markdown
      python3Packages.torrentool
      python3Packages.zhconv-rs
    ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/moviepilot
    cp -r . $out/share/moviepilot/
    chmod -R u+w $out/share/moviepilot

    cp -r ${frontendDist}/. $out/share/moviepilot/public/
    chmod -R u+w $out/share/moviepilot/public
    printf '%s\n' "${sources."moviepilot-frontend".version}" > $out/share/moviepilot/public/version.txt
    cp ${frontendRuntime}/libexec/moviepilot/service.js $out/share/moviepilot/public/service.js
    cp -r ${frontendRuntime}/libexec/moviepilot/node_modules $out/share/moviepilot/public/node_modules
    cp ${frontendRuntime}/libexec/moviepilot/package.json $out/share/moviepilot/public/package.json

    cp -r ${resourcesDir}/. $out/share/moviepilot/app/helper/

    mkdir -p $out/bin
    makeWrapper ${pkgs.python3Packages.python.interpreter} $out/bin/moviepilot \
      --chdir $out/share/moviepilot \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]} \
      --prefix PYTHONPATH : ${pkgs.python3Packages.makePythonPath propagatedBuildInputs} \
      --run 'export CONFIG_DIR="''${CONFIG_DIR:-''${XDG_CONFIG_HOME:-$HOME/.config}/moviepilot}"; mkdir -p "$CONFIG_DIR"' \
      --add-flags "-m app.cli"

    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/jxxghp/MoviePilot/releases/tag/v${version}";
    description = "Media automation platform for downloads, organization, scraping and notifications";
    homepage = "https://github.com/jxxghp/MoviePilot";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = [
      {
        github = "zhyiheihei";
        name = "zhyiheihei";
      }
    ];
    mainProgram = "moviepilot";
  };
}
