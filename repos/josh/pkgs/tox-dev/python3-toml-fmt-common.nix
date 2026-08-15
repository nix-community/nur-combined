{
  lib,
  python3Packages,
  fetchPypi,
  nix-update-script,
}:
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "toml-fmt-common";
  version = "1.3.5";

  pyproject = true;
  __structuredAttrs = true;

  src = fetchPypi {
    pname = "toml_fmt_common";
    inherit (finalAttrs) version;
    hash = "sha256-DsaJElvaZQv4q5Y0CquY0neTuNUxUQ9fVd6RpgI0CRY=";
  };

  # pypa-build checks build requirements even with --no-isolation, and nixpkgs'
  # uv-build is past the upper bound upstream pins.
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"uv-build<0.8,>=0.7.22"' '"uv-build"'
  '';

  build-system = with python3Packages; [
    uv-build
  ];

  pythonImportsCheck = [ "toml_fmt_common" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "Common logic to the TOML formatters";
    homepage = "https://github.com/tox-dev/toml-fmt";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
