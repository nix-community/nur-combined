{
  lib,
  fetchPypi,
  buildPythonPackage,
  rustPlatform,
  pkg-config,
  libopus,
  numpy,
  nix-update-script,
}:
buildPythonPackage (finalAttrs: {
  pname = "sphn";
  version = "0.2.1";
  __structuredAttrs = true;
  pyproject = true;

  # The git repository has no Cargo.lock; the sdist does.
  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-Oxmx/s5n2XnYQIBFi+1UXR9V3cWrrGyl3q4mcqGEx/4=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-Cqt5d6rQRFPcCWkgsVgxJytXogeY4K8GCbDWuZrKD9I=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    pkg-config
  ];

  # Use the system libopus rather than the bundled copy.
  buildInputs = [ libopus ];

  dependencies = [ numpy ];

  pythonImportsCheck = [ "sphn" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Python bindings for symphonia/opus to read and write audio files";
    homepage = "https://github.com/kyutai-labs/sphn";
    license = lib.licenses.OR [
      lib.licenses.mit
      lib.licenses.asl20
    ];
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
