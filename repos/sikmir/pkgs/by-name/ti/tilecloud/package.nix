{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "tilecloud";
  version = "1.14.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "camptocamp";
    repo = "tilecloud";
    tag = finalAttrs.version;
    hash = "sha256-hyPktwTADOHekPvkvtqoLctlz3FSrAZyUUVx0ZX63Rs=";
  };

  pythonRelaxDeps = true;

  patches = [ ./set-tmpl-path.patch ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "0.0.0"' 'version = "${finalAttrs.version}"'
  '';

  build-system = with python3Packages; [
    poetry-core
    poetry-dynamic-versioning
  ];

  dependencies = with python3Packages; [
    azure-core
    azure-storage-blob
    azure-identity
    boto3
    bottle
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
    # bogus entry point, c2cciutils module isn't part of tilecloud
    rm $out/bin/c2cciutils
  '';

  meta = {
    description = "Tools for managing tiles";
    homepage = "https://github.com/camptocamp/tilecloud";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
