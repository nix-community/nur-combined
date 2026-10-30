{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  fetchPypi,
  setuptools,
  bleak,
  pillow,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "dymo-bluetooth";
  version = "0.1.3";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) version;
    pname = "dymo_bluetooth";
    hash = "sha256-5fmSbGbBIGkj0cML9iiyD/GH/m/wzCUmffKrBSStn2U=";
  };

  # might be a bad idea
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "bleak~=1.1.1" "bleak" \
      --replace-fail "pillow~=11.0.0" "pillow"
  '';

  build-system = [ setuptools ];

  dependencies = [ bleak pillow typing-extensions ];
})
