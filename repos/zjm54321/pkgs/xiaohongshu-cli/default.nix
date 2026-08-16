{
  fetchFromGitHub,
  fetchurl,
  lib,
  python3Packages,
}:
let
  inherit (python3Packages)
    browser-cookie3
    buildPythonPackage
    click
    fetchPypi
    hatchling
    httpx
    language-tags
    lxml
    numpy
    orjson
    platformdirs
    playwright
    pycryptodome
    poetry-core
    pysocks
    pyyaml
    qrcode
    requests
    rich
    screeninfo
    tqdm
    typing-extensions
    ua-parser
    ;

  apify-fingerprint-datapoints = buildPythonPackage rec {
    pname = "apify-fingerprint-datapoints";
    version = "0.15.0";
    pyproject = true;

    src = fetchPypi {
      pname = "apify_fingerprint_datapoints";
      inherit version;
      hash = "sha256-V3b+c/6qORAmXK5VWZVSsJjzpxbYhyyaDCKV/yu2gNw=";
    };

    build-system = [ hatchling ];

    doCheck = false;
  };

  browserforge = buildPythonPackage rec {
    pname = "browserforge";
    version = "1.2.4";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "daijro";
      repo = "browserforge";
      rev = "v${version}";
      hash = "sha256-8mh1Wok96rwUNAdnaoI1VYkyNr50JX/K7o04n/epuMo=";
    };

    build-system = [ poetry-core ];

    propagatedBuildInputs = [
      apify-fingerprint-datapoints
      click
      httpx
      orjson
      rich
    ];

    doCheck = false;
  };

  camoufox = buildPythonPackage rec {
    pname = "camoufox";
    version = "0.4.11";
    format = "wheel";

    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/c6/7b/a2f099a5afb9660271b3f20f6056ba679e7ab4eba42682266a65d5730f7e/camoufox-0.4.11-py3-none-any.whl";
      hash = "sha256-g4ZNQ00VmnVmmQqmUkQpqNGoWcv4TS9k70qfKefS5f8=";
    };

    propagatedBuildInputs = [
      browserforge
      click
      language-tags
      lxml
      numpy
      orjson
      platformdirs
      playwright
      pysocks
      pyyaml
      requests
      screeninfo
      tqdm
      typing-extensions
      ua-parser
    ];

    doCheck = false;
  };

  xhshow = buildPythonPackage rec {
    pname = "xhshow";
    version = "0.1.9";
    format = "wheel";

    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/7f/c0/2783314af317b7207422e94f74302dbe32c5c9a1641bcfe11c4c073b0b04/xhshow-0.1.9-py3-none-any.whl";
      hash = "sha256-xLDTj0dGuKP5wI/P5GKPgciHsnx2t7pz+mH/mQ0YOdw=";
    };

    propagatedBuildInputs = [ pycryptodome ];

    doCheck = false;
  };
in
buildPythonPackage rec {
  pname = "xiaohongshu-cli";
  version = "0.6.4";
  pyproject = true;

  src = fetchPypi {
    pname = "xiaohongshu_cli";
    inherit version;
    hash = "sha256-kFiup9sTA09YTxWwRLNmudBASaRThiymBZjnjbnzzY4=";
  };

  build-system = [ hatchling ];

  propagatedBuildInputs = [
    browser-cookie3
    camoufox
    click
    httpx
    pycryptodome
    pyyaml
    qrcode
    rich
    xhshow
  ];

  doCheck = false;

  meta = {
    description = "Xiaohongshu command-line interface";
    homepage = "https://pypi.org/project/xiaohongshu-cli/";
    mainProgram = "xhs";
    platforms = lib.platforms.linux;
  };
}
