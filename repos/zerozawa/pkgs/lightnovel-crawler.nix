{
  lib,
  python3Packages,
  fetchFromGitHub,
  fetchPypi,
  fetchurl,
  makeWrapper,
  calibre,
}:
let
  # exejs — JS execution engine, replaces PyExecJS
  exejs = python3Packages.buildPythonPackage rec {
    pname = "exejs";
    version = "0.0.7";
    format = "wheel";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/b4/2f/a9786ef0130b2de80ed2273a43e0ca7c86333ac61de6b6c9b4307b8fd66b/exejs-0.0.7-py3-none-any.whl";
      hash = "sha256-upLNcuzFBweJvSQYV49p/i6h3plCwKkBhUSehV8oMgE=";
    };
    doCheck = false;
  };

  # lncrawl-scraper — HTTP scraper with Cloudflare bypass (extracted from bundled cloudscraper)
  lncrawl-scraper = python3Packages.buildPythonPackage rec {
    pname = "lncrawl-scraper";
    version = "0.2.4";
    pyproject = true;
    src = fetchPypi {
      pname = "lncrawl_scraper";
      inherit version;
      hash = "sha256-y2UzS8h/JkqMooYImVoljM84GqNJuAQnaPVuRM41hWg=";
    };
    build-system = with python3Packages; [ hatchling ];
    propagatedBuildInputs = with python3Packages; [
      beautifulsoup4
      brotli
      lxml
      requests
      exejs
    ];
    # curl-cffi is an optional C/Rust extension used by [all] extra
    pythonRemoveDeps = [ "curl-cffi" ];
    doCheck = false;
  };

  # Helper for missing packages not in nixpkgs
  python-box = python3Packages.buildPythonPackage rec {
    pname = "python-box";
    version = "7.3.2";
    pyproject = true;
    src = fetchPypi {
      pname = "python_box";
      inherit version;
      hash = "sha256-AouZFxKeZ/MRky2TNHuKTxtQDXpaKHDuPANfTnsZQDs=";
    };
    build-system = with python3Packages; [ setuptools ];
    doCheck = false;
  };

  readability-lxml = python3Packages.buildPythonPackage rec {
    pname = "readability-lxml";
    version = "0.8.1";
    pyproject = true;
    src = fetchPypi {
      pname = "readability-lxml";
      inherit version;
      hash = "sha256-5R/qVrWQmq+IbTB9SOeeCWKTJVr6Vnt9CLypTSWxpOE=";
    };
    build-system = with python3Packages; [ setuptools ];
    propagatedBuildInputs = with python3Packages; [
      beautifulsoup4
      lxml
      cssselect
      chardet
    ];
    doCheck = false;
  };

  questionary = python3Packages.buildPythonPackage rec {
    pname = "questionary";
    version = "2.1.0";
    pyproject = true;
    src = fetchPypi {
      pname = "questionary";
      inherit version;
      hash = "sha256-YwLN1kWxlmfY9uZjR3TpU4v80arZvih+dD2Wysr5VYc=";
    };
    build-system = with python3Packages; [ poetry-core ];
    propagatedBuildInputs = with python3Packages; [
      prompt-toolkit
    ];
    doCheck = false;
  };

  pyease-grpc = python3Packages.buildPythonPackage rec {
    pname = "pyease-grpc";
    version = "1.8.0";
    format = "wheel";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/5c/61/c6115917527812eca3fd147cd389ef33a0bc342de7545c34f8125682e1aa/pyease_grpc-1.8.0-py3-none-any.whl";
      hash = "sha256-aaBRF8+I8xCze/RVtRo/o1LqClN9eJSGepHrdExrJ6E=";
    };
    propagatedBuildInputs = with python3Packages; [
      grpcio
      protobuf
      requests
    ];
    pythonRemoveDeps = [ "grpcio" ];
    doCheck = false;
  };
in
python3Packages.buildPythonApplication rec {
  pname = "lightnovel-crawler";
  version = "4.11.0";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "lncrawl";
    repo = "lightnovel-crawler";
    rev = "v${version}";
    hash = "sha256-B7ayTJ7Vh1etW0ESZVupUjWxkn1Rq1ukxORHh7V7Wmg=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  # Python dependencies from upstream pyproject.toml
  # Some packages not in nixpkgs are provided as local helpers above
  propagatedBuildInputs = with python3Packages; [
    alembic
    base58
    beautifulsoup4
    brotli
    colorama
    ebooklib
    fastapi
    html5lib
    imap-tools
    httpx
    humanize
    lxml
    openai
    passlib
    pillow
    psycopg
    pycryptodome
    pyparsing
    python-dateutil
    python-dotenv
    python-jose
    python-slugify
    regex
    requests
    requests-toolbelt
    sqlmodel
    tqdm
    typer
    uvicorn
    zstd
    pyyaml
    # Local helper packages for missing deps
    exejs
    lncrawl-scraper
    python-box
    readability-lxml
    questionary
    pyease-grpc
  ];

  pythonImportsCheck = [ "lncrawl" ];

  pythonRemoveDeps = [ "nodriver" ];

  doCheck = false;

  postFixup = ''
    # Wrap all entry points to inject Calibre PATH for ebook-convert
    for binary in $out/bin/lncrawl $out/bin/lightnovel-crawler $out/bin/lightnovel_crawler; do
      if [ -e "$binary" ]; then
        wrapProgram "$binary" --prefix PATH : "${calibre}/bin"
      fi
    done
  '';

  meta = with lib; {
    description = "Download lightnovels from various online sources and generate e-books";
    homepage = "https://github.com/lncrawl/lightnovel-crawler";
    license = with licenses; [ gpl3Only ];
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [ fromSource ];
    mainProgram = "lncrawl";
  };
}
