{ lib
, buildPythonPackage
, fetchFromGitHub
, callPackage
, einops
, pytorch
, torchvision
, cudaPackages
, symlinkJoin
, timm
, which
, ninja
, cudaArchList ? [ "8.6+PTX" ] # pytorch.cudaArchList
}:
let
  lastUpdated = "2022-05-13";
  version = "unstable-${lastUpdated}";

  src = fetchFromGitHub {
    owner = "Tangshitao";
    repo = "QuadTreeAttention";
    rev = "a74428c9ca64828e4e7feaee601fce828389c4fe";
    hash = "sha256-mxX5YzTY+aZTL2y4W71iQT9rljQdd18JGbXJ63yZQHs=";
  };

  cudaJoined = symlinkJoin {
    name = "cudatoolkit-root";
    paths = with cudaPackages; [
      cuda_nvcc
      cuda_nvrtc
      cuda_cudart
      libcublas
      libcusparse
      libcusolver
      cuda_cccl # <thrust/*>
    ];
    postBuild = ''
      ln -s $out/lib $out/lib64
    '';
  };

  quad-tree-attention = buildPythonPackage {
    pname = "quad-tree-attention";
    inherit version;

    src = "${src}/QuadTreeAttention";

    # THCState removed from pytorch
    # they weren't using that variable anyway
    postPatch = ''
      sed -i '/extern THCState/d' QuadtreeAttention/src/value_aggregation.cpp
      sed -i '/name=/a packages=["QuadtreeAttention", "QuadtreeAttention.modules", "QuadtreeAttention.functions"],' setup.py
      touch QuadtreeAttention/__init__.py
      touch QuadtreeAttention/modules/__init__.py
      touch QuadtreeAttention/functions/__init__.py
    '';

    buildInputs = [
      pytorch.dev
    ];
    nativeBuildInputs = [
      which
      ninja
    ];

    CUDA_HOME = "${cudaJoined}";
    TORCH_CUDA_ARCH_LIST = "${lib.concatStringsSep ";" cudaArchList}";

    checkInputs = [
      (einops.overridePythonAttrs (a: { doCheck = false; }))
      torchvision
      timm
    ];

    pythonImportsCheck = [
      "QuadtreeAttention"
      "QuadtreeAttention.functions.quadtree_attention"
      "QuadtreeAttention.modules.quadtree_attention"
      "score_computation_cuda"
      "value_aggregation_cuda"
    ];

    passthru = {
      inherit pytorch;

      feature-matching = callPackage (import ./feature-matching.nix src) { };
    };

    meta = with lib; {
      maintainers = [ maintainers.SomeoneSerge ];
      platforms = platforms.linux;
      broken = !pytorch.cudaSupport;
    };
  };
in
quad-tree-attention
