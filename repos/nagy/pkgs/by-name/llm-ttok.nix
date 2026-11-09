{
  lib,
  fetchPypi,
  python3,
  nix-update-script,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {

  pname = "llm-ttok";
  version = "1.0";
  format = "pyproject";

  src = fetchPypi {
    pname = "ttok";
    version = finalAttrs.version;
    hash = "sha256-tB6fYkFOFSmoSXH/zR+Gi+GwAeP64SQpZooebMEpCm4=";
  };

  # Upstream pins uv_build <0.12.0. Relax the pin to use the nixpkgs uv-build.
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'uv_build>=0.11.0,<0.12.0' 'uv_build>=0.11.0'
  '';

  build-system = [
    python3.pkgs.uv-build
  ];

  dependencies = [
    python3.pkgs.click
    python3.pkgs.tiktoken
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "Count and truncate text based on tokens";
    homepage = "https://github.com/simonw/ttok";
    changelog = "https://github.com/simonw/ttok/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "ttok";
  };
})
