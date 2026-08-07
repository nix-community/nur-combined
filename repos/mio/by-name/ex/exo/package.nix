{
  lib,
  stdenv,
  python313Packages,
  fetchFromGitHub,
  rustPlatform,
  darwin,
  apple-sdk_15 ? null,
}:

let
  pname = "exo";
  version = "1.0.71";

  src = fetchFromGitHub {
    owner = "exo-explore";
    repo = "exo";
    rev = "v${version}";
    hash = "sha256-k3jtrJCxLx8nq1R70CtZWFyNVXEa5Ltw0MgdA0qFVXA=";
  };

  exo_pyo3_bindings = python313Packages.buildPythonPackage {
    pname = "exo-pyo3-bindings";
    version = "0.2.1";
    inherit src;
    
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-gwOdA2sHz8n4GfNjK+OYmttXUTle4WYmAE2Y0KXYrwg=";
    };

    pyproject = true;
    build-system = [ rustPlatform.maturinBuildHook ];

    nativeBuildInputs = [
      rustPlatform.cargoSetupHook
    ];

    buildInputs = lib.optionals (stdenv.hostPlatform.isDarwin && apple-sdk_15 != null) [
      apple-sdk_15
    ];

    maturinBuildFlags = [ "-m" "rust/exo_pyo3_bindings/Cargo.toml" ];
  };

in
python313Packages.buildPythonApplication {
  inherit pname version src;

  pyproject = true;

  build-system = [
    python313Packages.hatchling
  ];

  dependencies = with python313Packages; [
    aiofiles
    aiohttp
    pydantic
    fastapi
    filelock
    rustworkx
    huggingface-hub
    psutil
    loguru
    exo_pyo3_bindings
    anyio
    mlx
    mlx-lm
    tiktoken
    hypercorn
    openai-harmony
    httpx
    tomlkit
    mflux
    python-multipart
    msgspec
    zstandard
    mlx-vlm
    transformers
  ];

  prePatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'requires = ["uv_build>=0.8.9,<0.9.0"]' 'requires = ["hatchling"]' \
      --replace-fail 'build-backend = "uv_build"' 'build-backend = "hatchling.build"' \
      --replace-fail '"types-aiofiles>=24.1.0.20250708",' "" \
      --replace-fail '"anyio==4.11.0",' '"anyio",' \
      --replace-fail '"mflux==0.17.2; sys_platform == '"'darwin'"'",' '"mflux; sys_platform == '"'darwin'"'",' \
      --replace-fail '"mlx==0.31.2; sys_platform == '"'darwin'"'",' '"mlx; sys_platform == '"'darwin'"'",' \
      --replace-fail '"transformers>=5.0.0,<5.4.0",' '"transformers>=5.0.0",'

    substituteInPlace src/exo/utils/channels.py \
      --replace-fail 'MemoryObjectStreamState' '_MemoryObjectStreamState'
  '';

  # Disable tests since they might require network or GPU
  doCheck = false;

  postInstall = ''
    mkdir -p $out/share/exo/dashboard
    touch $out/share/exo/dashboard/index.html
    cp -r resources $out/share/exo/
  '';

  makeWrapperArgs = [
    "--set" "EXO_RESOURCES_DIR" "$out/share/exo/resources"
    "--set" "EXO_DASHBOARD_DIR" "$out/share/exo/dashboard"
  ];

  meta = with lib; {
    description = "Run your own AI cluster at home with everyday devices";
    homepage = "https://github.com/exo-explore/exo";
    license = licenses.asl20;
    platforms = [ "x86_64-darwin" "aarch64-darwin" ];
    mainProgram = "exo";
  };
}
