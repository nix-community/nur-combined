{ lib
, buildPackages
, buildPythonPackage
, cudaPackages
, einops
, fetchFromGitHub
, formats
, imageio
, loguru
, matplotlib
, opencv4
, pybind11
, python
, runCommand
, scipy
, setuptools
, some-datasets
, stdenv
, symlinkJoin
, tensorboard
, timm
, torch
, torchvision
, videoflow
, which
, yacs
, fetchtimm
, torch-kernel-generic
}:

let
  hubCache = fetchtimm {
    name = "videoflow-hub-cache";
    modelNames = [ "twins_svt_large" ];
    outputHash = "sha256-rwyFEPrW5JbUXg3NTxclpSTVXbcKlNxaXfJMog92daE=";
  };

  corr_kernel = torch-kernel-generic {
    pname = "videoflow-alt-cuda-corr";
    inherit (videoflow) version;

    src = "${videoflow.src}/alt_cuda_corr";

    pythonImportsCheck = [
      "alt_cuda_corr"
    ];

    meta = with lib; {
      description = "alt_cuda_corr kernel for VideoFlow";
      homepage = "https://github.com/XiaoyuShi97/VideoFlow";
      # https://github.com/XiaoyuShi97/VideoFlow/blame/51489304db6e75fbdd9ff64d4656c1d120b5a673/README.md#L115
      license = licenses.asl20;
      maintainers = with maintainers; [ ];
      platforms = platforms.all;
    };
  };

  videoflow =
    buildPythonPackage rec {
      pname = "videoflow";
      version = "unstable-2023-09-20";
      format = "pyproject";

      outputs = [ "out" "data" ];

      src = fetchFromGitHub {
        owner = "XiaoyuShi97";
        repo = "VideoFlow";
        rev = "51489304db6e75fbdd9ff64d4656c1d120b5a673";
        hash = "sha256-M9AHmEo5pTCvhV3G6lMfVuZ911D2VP8Srv/ZPGFrH5w=";
      };

      pyprojectToml = (formats.toml { }).generate "pyproject.toml"
        {
          project.name = pname;
          project.version = lib.concatStringsSep "." (lib.take 3 (lib.lists.reverseList (lib.versions.splitVersion version)));
          build-system.requires = [ "setuptools" ];
          build-system.build-backend = "setuptools.build_meta";

          project.scripts = {
            "videoflow-inference" = "VideoFlow.inference:entrypoint";

            "videoflow-train-BOFNet" = "VideoFlow.train_BOFNet:entrypoint";
            "videoflow-train-MOFNet" = "VideoFlow.train_MOFNet:entrypoint";

            "videoflow-evaluate-BOFNet" = "VideoFlow.evaluate_BOFNet:entrypoint";
            "videoflow-evaluate-MOFNet" = "VideoFlow.evaluate_MOFNet:entrypoint";
          };
        };

      postPatch = ''
        rm -rf alt_cuda_corr/{build,*.egg-info,dist}

        find -iname '*.py' -exec \
          sed -i \
            -e 's/sys.path.append.*$/pass/' \
            -e 's/^import utils/import VideoFlow.core.utils/' \
            -e 's/^from utils/from VideoFlow.core.utils/' \
            -e 's/^\(\s*\)from \(core\|configs\)/\1from VideoFlow.\2/' \
            '{}' '+'

        sed -i \
          -e 's/if __name__ == .__main__./def entrypoint()/' \
          *.py

        sed -i \
          -e '$a if __name__ == "__main__":' \
          -e '$a \ \ \ \ entrypoint()' \
          *.py

        sed -i "s|\./flow_dataset|$data/data/flow_dataset|" \
          core/datasets_3frames.py \
          core/datasets_multiframes.py

        mkdir -p src/VideoFlow
        mv configs core *.py src/VideoFlow/

        cat $pyprojectToml > pyproject.toml
      '';

      preInstall = ''
        mkdir -p "$data/data"
        mv \
          ./flow_datasets \
          ./flow_dataset_mf \
          ./demo_input_images \
          "$data/data/"
      '';

      nativeBuildInputs = [
        setuptools
      ];
      buildInputs = [
        cudaPackages.cuda_nvcc
      ];
      propagatedBuildInputs = [
        corr_kernel
        einops
        imageio
        loguru
        matplotlib
        opencv4
        scipy
        tensorboard
        timm
        torch
        torchvision
        yacs
      ];

      pythonImportsCheck = [
        "VideoFlow.configs"
        "VideoFlow.core"
        "VideoFlow.core.Networks"
        "VideoFlow.core.Networks.BOFNet"
        "VideoFlow.core.Networks.MOFNetStack"
        "VideoFlow.core.utils"
        "VideoFlow.core.utils.utils"
      ];

      passthru = rec {
        alt_cuda_corr = corr_kernel;

        datasetsMerged = some-datasets.extendModules {
          modules = [{
            models.videoflow = { inherit weights; };
          }];
        };

        weights = {
          BOF_kitti.name = "BOF_kitty.pth";
          BOF_kitti.hash = "sha256-xwQzP0rse3/xrUP7/jmNdKVTsCv8IJd2YBLVGPr4hMg=";
          BOF_kitti.cid = "QmULezZUvrL8GPv6oLgJjawEcxBmZMd6KuhfvmGY2rsFts";

          BOF_sintel.name = "BOF_sintel.pth";
          BOF_sintel.hash = "sha256-s9IBZiXfJugYVNqjfWn0IXiMk+zNhumGNl22jMMTwgo=";
          BOF_sintel.cid = "QmaMr7LJf6fGFaJnmwBDzThz1SbQudpppXpC1Sb88ema2s";

          MOF_kitti.name = "MOF_kitti.pth";
          MOF_kitti.hash = "";
          MOF_kitti.cid = "QmV6CgX9TRzxuPTyu615nXW7M7hjVPghBJ87V3PZpevrqR";

          MOF_sintel.name = "MOF_sintel.pth";
          MOF_sintel.hash = "sha256-+5+VNRYqVZwKqkKEHfDUKouC12AsKSUA/uVLhsposdM=";
          MOF_sintel.cid = "QmagvdPT746qHYKUGRbZCbZpjGwzH465guQPBjxts4wbxJ";

          MOF_things.name = "MOF_things.pth";
          MOF_things.hash = "";
          MOF_things.cid = "QmciHVJQcjis7r6nKxf97uJh7iGMyNCt37YAR8FZepxTSS";
        };

        inherit hubCache;
        tests.run-inference = runCommand "videoflow-run-inference"
          {
            nativeBuildInputs = [ videoflow ];
            requiredSystemFeatures = [ "cuda" ];
          } ''
          export HUGGINGFACE_HUB_CACHE=${hubCache}/data/huggingface
          ln -s "${datasetsMerged.config.models.videoflow.weights.MOF_sintel.package}/data" VideoFlow_ckpt
          videoflow-inference \
            --seq_dir "${videoflow.data}/data/demo_input_images" \
            --vis_dir "$out"
        '';
      };

      meta = with lib; {
        description = "Official implementation of ICCV2023 VideoFlow: Exploiting Temporal Cues for Multi-frame Optical Flow Estimation";
        homepage = "https://github.com/XiaoyuShi97/VideoFlow";
        # https://github.com/XiaoyuShi97/VideoFlow/blame/51489304db6e75fbdd9ff64d4656c1d120b5a673/README.md#L115
        license = licenses.asl20;
        maintainers = with maintainers; [ ];
        # mainProgram = "videoflow";
        platforms = platforms.all;
      };
    };

in
videoflow
