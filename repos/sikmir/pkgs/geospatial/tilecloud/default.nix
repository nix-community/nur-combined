{
  lib,
  fetchFromGitHub,
  python3Packages,
  c2cwsgiutils,
}:

python3Packages.buildPythonApplication rec {
  pname = "tilecloud";
  version = "1.12.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "camptocamp";
    repo = "tilecloud";
    rev = version;
    hash = "sha256-yblAOBp9anvsVnF9q8jwnMoyNG42K+E3antBe5pkS7Y=";
  };

  patches = [ ./set-tmpl-path.patch ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "\"poetry-plugin-drop-python-upper-constraint\"" "" \
      --replace-fail "\"poetry-plugin-tweak-dependencies-version\"," "" \
      --replace-fail "\"poetry-plugin-tweak-dependencies-version>=1.1.0\"," "" \
      --replace-fail "requests = \"2.32.3\"" "requests = \"*\"" \
      --replace-fail "Pillow = \"10.3.0\"" "Pillow = \"*\"" \
      --replace-fail "webob = \"1.8.8\"" "webob = \"*\""
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
    pillow
    prometheus_client
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
