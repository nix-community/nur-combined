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
  # Helper for missing packages not in nixpkgs
  js2py = python3Packages.buildPythonPackage rec {
    pname = "js2py";
    version = "0.74";
    pyproject = true;
    src = fetchPypi {
      pname = "Js2Py";
      inherit version;
      hash = "sha256-OfOmqoRpGA77o8hncnHfJ8MTMv0bRx3xryr1i4e4ly8=";
    };
    build-system = with python3Packages; [ setuptools ];
    propagatedBuildInputs = with python3Packages; [
      pyjsparser
      tzlocal
      six
    ];
    doCheck = false;
  };

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

  pyexecjs = python3Packages.buildPythonPackage rec {
    pname = "pyexecjs";
    version = "1.5.1";
    pyproject = true;
    src = fetchPypi {
      pname = "PyExecJS";
      inherit version;
      hash = "sha256-NMwdBwl2kYGD/3vcCtcfgVeokcknCMAMX7v/enafUFw=";
    };
    build-system = with python3Packages; [ setuptools ];
    propagatedBuildInputs = with python3Packages; [
      six
    ];
    doCheck = false;
  };

  pyease-grpc = python3Packages.buildPythonPackage rec {
    pname = "pyease-grpc";
    version = "1.7.0";
    format = "wheel";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/70/26/f1437aedd58397cc3b572cedeb10e2f565fd508120a4b47dbcaacea586d9/pyease_grpc-1.7.0-py3-none-any.whl";
      hash = "sha256-J5BH4D8h9LZeviUdUnUEqPZNhMz6AotQu6DnMVMh8F4=";
    };
    propagatedBuildInputs = with python3Packages; [
      grpcio
      protobuf
      requests
    ];
    doCheck = false;
  };
in
python3Packages.buildPythonApplication rec {
  pname = "lightnovel-crawler";
  version = "4.0.1";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "lncrawl";
    repo = "lightnovel-crawler";
    rev = "v${version}";
    hash = "sha256-xFDMF64/Dlqq+iNjSPwskH5X6KzpHwbcIoo+mJFQrUI=";
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
    selenium
    sqlmodel
    tqdm
    typer
    uvicorn
    zstd
    pyyaml
    pywebview
    # Local helper packages for missing deps
    js2py
    python-box
    readability-lxml
    questionary
    pyexecjs
    pyease-grpc
  ];

  pythonImportsCheck = [ "lncrawl" ];

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
    broken = versionOlder python3Packages.pywebview.version "6.1";
    license = with licenses; [ gpl3Only ];
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [ fromSource ];
    mainProgram = "lncrawl";
  };
}
