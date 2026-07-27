{ lib
, buildPythonPackage
, fetchFromGitHub
, fetch-torch-hub
, numpy
, pillow
, prefix-python-modules
, setuptools
, some-util
, stdenv
, torch
, torchvision
}:

buildPythonPackage rec {
  pname = "dino";
  version = "unstable-2023-04-27";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "facebookresearch";
    repo = "dino";
    rev = "7c446df5b9f45747937fb0d72314eb9f7b66930a";
    hash = "sha256-4gDfMbcSLOxJz25vBgc6V/C3HLGWJg9N+xscAJq7IBk=";
  };

  postPatch =
    ''
      cp ${./pyproject.toml} pyproject.toml

      sed -i \
        -e 's/^\(\s*\)\(state_dict = torch.hub\)/\1print(f"Going to download {url=} via torch.hub")\n\1\2/' \
        utils.py

      prefix-python-modules . --prefix $pname
    '';

  nativeBuildInputs = [
    setuptools
    prefix-python-modules
  ];
  propagatedBuildInputs = [
    numpy
    pillow
    torch
    torchvision
  ];
  pythonImportsCheck = [
    "dino.main_dino"
    "dino.utils"
  ];

  passthru = rec {
    merged = with lib; with types; (lib.evalModules {
      modules = [
        { options.weights = mkOption { type = attrsOf some-util.types.RemoteFile; }; }
        {
          options.weights = mkOption {
            type = attrsOf (submodule ({ config, ... }: {
              options.modelName = mkOption { type = str; };
              options.relPath = mkOption { type = str; };
              options.patchSize = mkOption { type = nullOr int; default = null; };
              config.urls = [
                "https://dl.fbaipublicfiles.com/dino/${config.relPath}"
              ];
            }));
          };
        }
        { inherit weights; }
      ];
    }).config;
    weights = {
      vit_small_16_pretrain = {
        modelName = "vit_small";
        patchSize = 16;
        relPath = "dino_deitsmall16_pretrain/dino_deitsmall16_pretrain.pth";
        hash = "sha256-t6oVlVUqvzHrg08FIN1NhnTmOQIxPWhDdGpoO0JpVFg=";
        fetcher = { hash, urls, ... }: fetch-torch-hub { inherit hash urls; };
      };
      vit_small_16 = {
        modelName = "vit_small";
        patchSize = 16;
        relPath = "dino_deitsmall16_pretrain/dino_deitsmall16_linearweights.pth";
        hash = "sha256-HGloePfrx8yoYbaOcYS+EqMEomBFqgQR5ICrB/ONoGc=";
        fetcher = { hash, urls, ... }: fetch-torch-hub { inherit hash urls; };
      };
      vit_small_8 = {
        modelName = "vit_small";
        patchSize = 8;
        relPath = "dino_deitsmall8_pretrain/dino_deitsmall8_linearweights.pth";
        hash = "sha256-4de2IovOpWpRf58CF1cKgFXnD3N2UBmOBWC/SMS6uQI=";
        fetcher = { hash, urls, ... }: fetch-torch-hub { inherit hash urls; };
      };
      vit_base_16 = {
        modelName = "vit_base";
        patchSize = 16;
        relPath = "dino_vitbase16_pretrain/dino_vitbase16_linearweights.pth";
        hash = "sha256-8X5llwyuWhgTAA8JzdjXjykClbUSMIqgL0eao3woR78=";
        fetcher = { hash, urls, ... }: fetch-torch-hub { inherit hash urls; };
      };
      vit_base_8 = {
        modelName = "vit_base";
        patchSize = 8;
        relPath = "dino_vitbase8_pretrain/dino_vitbase8_linearweights.pth";
        hash = "sha256-OImDK7sOBQdBknAMgnKWNt3ZJO+4DYLZYu+3tCGJmlY=";
        fetcher = { hash, urls, ... }: fetch-torch-hub { inherit hash urls; };
      };
      resnet50 = {
        modelName = "resnet50";
        relPath = "dino_resnet50_pretrain/dino_resnet50_linearweights.pth";
        hash = "sha256-uNhXZp1mVZ8FVMAdJjFpSg0Mcf6BrdbMlhmChVzHWbg=";
        fetcher = { hash, urls, ... }: fetch-torch-hub { inherit hash urls; };
      };
    };
  };

  meta = with lib; {
    description = "PyTorch code for Vision Transformers training with the Self-Supervised learning method DINO";
    homepage = "https://github.com/facebookresearch/dino";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    mainProgram = "dino";
    platforms = platforms.all;
  };
}
