{
  fetchurl,
  lib,
  buildPythonPackage,
  nix-update-script,
  setuptools,
  # Dependencies
  httpx,
}:

buildPythonPackage (finalAttrs: {
  pname = "xue";
  version = "0.0.34";
  pyproject = true;

  src = fetchurl {
    url = "mirror://pypi/x/xue/xue-${finalAttrs.version}.tar.gz";
    hash = "sha256-1fTAmCuZYVOrNihGQZfGK0pwV910KD19KK+MYkuyA3w=";
  };
  build-system = [ setuptools ];

  propagatedBuildInputs = [ httpx ];

  pythonImportsCheck = [ "xue" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    description = "Minimalist web front-end framework composed of HTMX and Python";
    homepage = "https://pypi.org/project/xue/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})
