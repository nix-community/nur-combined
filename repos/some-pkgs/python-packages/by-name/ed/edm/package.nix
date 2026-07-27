{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, prefix-python-modules
, cudaPackages
, edm
, torch
, torchvision
, imageio
, imageio-ffmpeg
, requests
, pillow
, scipy
, click
, pyspng
, python
, singularity-tools
, nixglhost
, runCommand
}:

buildPythonPackage rec {
  pname = "edm";
  version = "unstable-2023-01-31";
  pyproject = true;

  pyprojectToml = ./pyproject.toml;

  src = fetchFromGitHub {
    owner = "NVlabs";
    repo = "edm";
    rev = "62072d2612c7da05165d6233d13d17d71f213fee";
    hash = "sha256-mCyC8JxTN+ng7Wswa9htBUeErKGuLlxPc6gbSmJIh4c=";
  };

  # Unfortunately, we cannot easily isolate edm's modules entirely and stay
  # compatible with the old pickles: it's not enough to map the names in the
  # Unpickler, because torch_info.persistence hard-codes the module names at
  # the application level (we'd have to rewrite the content of the pickles).
  #
  # We resort to the sys.modules hack, which means that it's safe to compose
  # edm with other modules in the same site-packages, but not in the same
  # python process
  postPatch = ''
    prefix-python-modules . --prefix "$pname"

    cat << EOF >> "$pname/__init__.py"
    import sys
    import $pname.torch_utils
    sys.modules["torch_utils"] = $pname.torch_utils
    EOF

    cat "$pyprojectToml" > pyproject.toml
  '';

  nativeBuildInputs = [
    setuptools
    prefix-python-modules
  ];

  propagatedBuildInputs = [
    torch
    torchvision
    imageio
    imageio-ffmpeg
    requests
    pillow
    scipy
    pyspng
    click
  ];

  pythonImportsCheck = [
    "edm.dataset_tool"
    "edm.fid"
    "edm.example"
    "edm.train"
    "edm.dnnlib.util"
  ];

  passthru.pythonWith = python.withPackages (_: [ edm ]);
  passthru.image = singularity-tools.buildImage {
    name = "edm";
    memSize = 4 * 1024; # MiB
    diskSize = 20 * 1024; # MiB
    contents = [
      nixglhost
      cudaPackages.saxpy
      (python.withPackages (_: [ edm ]))
    ];
  };
  passthru.dnnlibCache = runCommand "edm-dnnlib-cache"
    {
      nativeBuildInputs = [ edm.pythonWith ];
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = "sha256-xzG8f40BVvjVFH2MlNX9TNoKOEDSNJ8nYidtiC3mV0o=";
      env.urls = builtins.concatStringsSep "\n"
        (map (x: "https://nvlabs-fi-cdn.nvidia.com/edm/pretrained/${x}") [
          "edm-cifar10-32x32-cond-vp.pkl"
          "edm-ffhq-64x64-uncond-vp.pkl"
          "edm-afhqv2-64x64-uncond-vp.pkl"
          "edm-imagenet-64x64-cond-adm.pkl"
        ]);
    }
    ''
      export HOME=$out
      python << EOF
      import os
      import edm.dnnlib as dnnlib

      for url in os.environ["urls"].split():
        with dnnlib.util.open_url(url) as f:
          pass
      EOF
    '';
  passthru.gpuChecks.example = runCommand "edm-samples"
    {
      nativeBuildInputs = [ edm.pythonWith ];

      # Cf. https://github.com/NixOS/nixpkgs/pull/256230
      requiredSystemFeatures = [ "cuda" ];
    }
    ''
      set -e
      mkdir tmp
      cd tmp
      HOME="${edm.dnnlibCache}" python -m edm.example
      cd ..
      cp -r tmp/ $out
    '';

  meta = with lib; {
    description = "Elucidating the Design Space of Diffusion-Based Generative Models (EDM)";
    homepage = "https://github.com/NVlabs/edm";
    license = licenses.cc-by-nc-sa-40;
    maintainers = with maintainers; [ ];
    mainProgram = "edm";
    platforms = platforms.all;
  };
}
