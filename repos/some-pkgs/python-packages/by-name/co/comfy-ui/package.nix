{ lib
, accelerate
, aiohttp
, buildPythonPackage
, einops
, fetchFromGitHub
, formats
, makeWrapper
, opencv4
, pillow
, prefix-python-modules
, psutil
, pytestCheckHook
, python
, pyyaml
, safetensors
, scikit-image
, scipy
, setuptools
, stable-diffusion-webui
, torch
, torchsde
, torchvision
, tqdm
, transformers
, websocket-client
}:

let
  sd-webui-module = "${stable-diffusion-webui}/${python.sitePackages}/sd_webui";
  relativeModelPaths = (formats.yaml { }).generate "extra-model-paths.yaml" {
    a111 = {
      checkpoints = "sd_webui_data/models/Stable-diffusion";
      configs = "models/Stable-diffusion";
      vae = "models/VAE";
      loras = ''
        models/Lora
        models/LyCORIS
      '';
      upscale_models = ''
        models/ESRGAN
        models/RealESRGAN
        models/SwinIR
      '';
      embeddings = "models/embeddings";
      hypernetworks = "models/hypernetworks";
      controlnet = "models/ControlNet";
    };
  };
in

buildPythonPackage rec {
  pname = "comfy-ui";
  version = "unstable-2023-11-06";
  pyproject = true;

  outputs = [ "out" "resources" ];

  src = fetchFromGitHub {
    owner = "comfyanonymous";
    repo = "ComfyUI";
    rev = "b3fcd64c6c9c57a8a83ceeff3e6eb7121b122f08";
    hash = "sha256-Nl862h0/+vL5TwC/AfU1eV8Mr1VKCbnOCndoTBfw6hw=";
  };

  patches = [
    ./0001-main.py-add-an-entrypoint.patch
    ./0002-comfy.model_management-fallback-to-cpu.patch
    ./0003-tests-inference-guard-cuda-references.patch
    ./0004-cli_args-add-extra-path.patch
    ./0005-folder_paths-allow-overriding-base_path.patch
    ./0006-folder_paths-in-temp-out-dirs-respect-overrides.patch
    ./0007-cli_args-make-it-possible-to-see-the-final-args.patch
    ./0008-options-os.environ-to-prevent-the-entrypoint-from-ig.patch
  ];

  postPatch = ''
    prefix-python-modules . --prefix comfy --exclude-glob '.*' --exclude-glob 'tests*'
    substituteInPlace comfy/main.py \
      --replace \
        "server = server." \
        "server = comfy.server."
    substituteInPlace tests/inference/test_inference.py \
      --replace \
        "'python','main.py'" \
        "'$out/bin/comfy-ui'"
    mv web/ comfy/
    cp ${./pyproject.toml} pyproject.toml
  '';

  nativeBuildInputs = [
    prefix-python-modules
    setuptools
    makeWrapper
  ];

  propagatedBuildInputs = [
    accelerate
    aiohttp
    einops
    pillow
    psutil
    pyyaml
    safetensors
    scipy
    torch
    torchsde
    torchvision
    tqdm
    transformers
  ];

  nativeCheckInputs = [
    # All the tests are "broken"
    # -> "0 collected tests"
    # -> manual checkPhase
    pytestCheckHook
    opencv4
    scikit-image
    websocket-client
  ];

  preCheck = ''
    export COMFY_BASE_PATH=$resources
  '';

  # Disables pytestCheckPhase
  checkPhase = ''
    runHook preCheck
    runHook postCheck
  '';

  pytestFlagsArray = [
    # Depends on unstaged 'tests/inference/baseline'
    "--ignore"
    "tests/compare"
    # Got download the weights for that...
    # "--ignore"
    # "tests/inference"
  ];

  pythonImportsCheck = [
    "comfy"
    # Attempts to open libcuda.so unless there's "--cpu" in `sys.path`:
    # "comfy.main"
  ];

  postCheck = ''
    echo Check whether the following modules can be imported: comfy.main
    python << EOF
    import sys
    sys.argv.append("--cpu")
    import comfy.main
    EOF
  '';

  postInstall = ''
    mkdir "$resources"
    cp -r models custom_nodes "$resources/"

    makeWrapper $out/bin/comfy-ui $out/bin/comfy-ui-relpaths \
      --add-flags '--extra-model-paths-config "${relativeModelPaths}"' \
      --set-default COMFY_BASE_PATH . \
      --set-default COMFY_FORCE_ARGS 1
  '';

  meta = with lib; {
    broken = true; # The build works, but the runtime is untested
    description = "The most powerful and modular stable diffusion GUI with a graph/nodes interface";
    homepage = "https://github.com/comfyanonymous/ComfyUI";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "comfy-ui-relpaths";
    platforms = platforms.all;
  };
}
