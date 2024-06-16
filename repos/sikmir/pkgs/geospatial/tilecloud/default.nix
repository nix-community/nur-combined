{
  lib,
  fetchFromGitHub,
  python3Packages,
  c2cwsgiutils,
}:

python3Packages.buildPythonApplication rec {
  pname = "tilecloud";
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "camptocamp";
    repo = "tilecloud";
    rev = version;
    hash = "sha256-rg85xlmPq5pSrHAjA+9YlkQLndhNha8+OsqbGqe8JSM=";
  };

  patches = [ ./set-tmpl-path.patch ];

  dependencies = with python3Packages; [
    azure-storage-blob
    azure-identity
    boto3
    bottle
    c2cwsgiutils
    pillow
    pyproj
    requests
    redis
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  # https://github.com/camptocamp/tilecloud/issues/391
  postInstall = ''
    site_packages=$out/lib/${python3Packages.python.libPrefix}/site-packages
    cp -r static tiles views $site_packages
    substituteInPlace $out/bin/tc-viewer --subst-var site_packages
  '';

  meta = {
    description = "Tools for managing tiles";
    homepage = "https://github.com/camptocamp/tilecloud";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
