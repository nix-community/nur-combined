{
  lib,
  fetchFromGitHub,
  python3,
  stdenv,
}:
stdenv.mkDerivation {
  pname = "feedsearch-crawler";
  version = "2022-05-28";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "DBeath";
    repo = "feedsearch-crawler";
    rev = "f49a6f5a07e796e359c4482fd29305b1a019f71f";
    hash = "sha256-pzvyeXzqdi8pRjk2+QjKhJfgtxbgVT6C08K9fhVFVmY=";
  };

  patches = [
    # fix for <https://github.com/aio-libs/aiohttp/issues/4581>
    #   where large feeds would timeout in an unrecoverable way
    ./0001-response-chunk-size.patch
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'w3lib = "^1.22.0"' 'w3lib = "*"' \
      --replace-fail 'aiodns = "^2.0.0"' 'aiodns = "*"' \
      --replace-fail 'uvloop = "^0.15.2"' 'uvloop = "*"'
  '';

  nativeBuildInputs = [
    python3.pkgs.poetry-core
    python3.pkgs.pypaBuildHook
    python3.pkgs.pypaInstallHook
  ];

  propagatedBuildInputs = with python3.pkgs; [
    aiodns
    aiohttp
    beautifulsoup4
    brotlipy
    cchardet
    feedparser
    python-dateutil
    uvloop
    w3lib
    yarl
  ];

  nativeCheckInputs = [
    python3.pkgs.pythonImportsCheckHook
  ];

  pythonImportsCheck = [
    "feedsearch_crawler"
  ];

  doCheck = true;
  strictDeps = true;

  meta = with lib; {
    homepage = "https://feedsearch.dev";
    description = "Crawl sites for RSS, Atom, and JSON feeds";
    license = licenses.mit;
    maintainers = with maintainers; [ colinsane ];
  };
}
