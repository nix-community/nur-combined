{
  lib,
  fetchFromGitHub,
  python3Packages,
  c2cwsgiutils,
}:

python3Packages.buildPythonApplication rec {
  pname = "tilecloud";
  version = "1.13.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "camptocamp";
    repo = "tilecloud";
    tag = version;
    hash = "sha256-nxTfMTKj0pXAzQPYRdh08Qi0u+WY865s3JtvdNy2eIQ=";
  };

  pythonRelaxDeps = true;

  patches = [ ./set-tmpl-path.patch ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "\"poetry-plugin-tweak-dependencies-version\"," "" \
      --replace-fail "\"poetry-plugin-tweak-dependencies-version>=1.1.0\"," ""
  '';

  build-system = with python3Packages; [
    poetry-core
    poetry-dynamic-versioning
  ];

  dependencies = with python3Packages; [
    azure-storage-blob
    azure-identity
    boto3
    bottle
    c2cwsgiutils
    cryptography
    pillow
    prometheus-client
    pyproj
    requests
    redis
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  # https://github.com/camptocamp/tilecloud/issues/391
  postInstall = ''
    site_packages=$out/lib/${python3Packages.python.libPrefix}/site-packages
    cp -r static tiles $site_packages
    substituteInPlace $out/bin/tc-viewer --subst-var site_packages
  '';

  meta = {
    description = "Tools for managing tiles";
    homepage = "https://github.com/camptocamp/tilecloud";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
