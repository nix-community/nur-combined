{ lib
, buildPythonPackage
, fetchFromGitHub
, gluestick
, matplotlib
, numpy
, omegaconf
, opencv4
, python
, pytlsd
, runCommand
, scikit-learn
, scipy
, seaborn
, setuptools
, some-util
, torch
, torchvision
, tqdm
, wheel
}:

buildPythonPackage rec {
  pname = "gluestick";
  version = "unstable-2023-10-05";
  pyproject = true;

  outputs = [ "out" "resources" ];

  src = fetchFromGitHub {
    owner = "cvg";
    repo = "GlueStick";
    rev = "0a6a1ae4569164d8fd1e4d24755d4dec6d9d7d60";
    hash = "sha256-LdDN//T1Blt0ohieuz2Mb1A238gLvVFoiggbeF69z3o=";
  };

  patches = [
    ./0006-gluestick.run-main-allow-overriding-weights.patch
    ./0007-gluestick.run-set_default_device-to-init-on-cuda.patch
  ];

  postPatch = ''
    rm setup.py
    cp ${./pyproject.toml} pyproject.toml
    substituteInPlace gluestick/models/superpoint.py \
      --replace "path = GLUESTICK_ROOT" "import os; path = os.environ.get('SUPERPOINT_WEIGHTS', None) or GLUESTICK_ROOT"
  '';

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    matplotlib
    numpy
    omegaconf
    opencv4
    pytlsd
    scikit-learn
    scipy
    seaborn
    setuptools
    torch
    torchvision
    tqdm
  ];

  pythonImportsCheck = [
    "gluestick"
    "gluestick.models"
    "gluestick.run"
  ];

  postInstall = ''
    mkdir "$resources"
    cp -rf resources "$resources/"
  '';

  passthru = rec {
    merged = with lib; with types; (lib.evalModules {
      modules = [
        { options.weights = mkOption { type = attrsOf some-util.types.RemoteFile; }; }
        {
          options.weights = mkOption {
            type = attrsOf (submodule ({ config, ... }: {
              options.modelName = mkOption { type = str; };
            }));
          };
        }
        { inherit weights; }
      ];
    }).config;
    weights = rec {
      v0_1_arxiv = {
        name = "v0_1_arxiv.pth";
        hash = "sha256-tNqVjkHGzQakNLfGNW+NvwBxpeiGrgPLV02/xrinOEg=";
        modelName = "gluestick-md";
        cid = "QmRHQZSky63ERp357PECwNAo2qmYdCBKe4neDcTuZ3f1ey";
        urls = [ "https://github.com/cvg/GlueStick/releases/download/v0.1_arxiv/checkpoint_GlueStick_MD.tar" ];
      };
    };
    tests = {
      run = runCommand "gluestick-run"
        {
          nativeBuildInputs = [
            gluestick
          ];
          env.MPLBACKEND = "AGG";
          env.SUPERPOINT_WEIGHTS = "${gluestick.resources}/resources/weights/superpoint_v1.pth";
        } ''
        export MPLCONFIGDIR=$TMPDIR/mpl
        gluestick-run \
          --weights ${gluestick.merged.weights.v0_1_arxiv.package}/data/v0_1_arxiv.pth \
          -img1 ${gluestick.resources}/resources/img1.jpg \
          -img2 ${gluestick.resources}/resources/img2.jpg
        mkdir $out
        cp *png $out/
      '';
    } // lib.optionalAttrs torch.cudaSupport {
      run-cuda = tests.run.overrideAttrs (_: {
        requiredSystemFeatures = [ "cuda" ];
      });
    };
  };

  meta = with lib; {
    description = "Inference code for GluleStick, a Joint Deep Matcher for Points and Lines (ICCV 2023)";
    homepage = "https://github.com/cvg/GlueStick";
    license = licenses.mit;
    maintainers = with maintainers; [ SomeoneSerge ];
  };
}
