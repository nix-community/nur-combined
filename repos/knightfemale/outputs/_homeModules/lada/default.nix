{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.lada;

  # Defaults match Lada's CLI defaults.
  # Model files are placed directly in the generated model directory;
  # a model whose name contains a relative path (for example "3rd_party/clean_youknow_video.pth") is placed in that subdirectory.
  defaultModels = [
    {
      name = "lada_mosaic_detection_model_v4_fast.pt";
      url = "https://huggingface.co/ladaapp/lada/resolve/main/lada_mosaic_detection_model_v4_fast.pt?download=true";
      hash = "sha256-mmtmDR0+N5fTlRXgiw5y/MWYFfOCefqnpKs3SrLB47Q=";
    }
    {
      name = "lada_mosaic_restoration_model_generic_v1.2.pth";
      url = "https://huggingface.co/ladaapp/lada/resolve/main/lada_mosaic_restoration_model_generic_v1.2.pth?download=true";
      hash = "sha256-1AQVJXbOZPtbLzFcAwYnCdrE9fhUiTSGbNAcgjyBBO4=";
    }
  ];

  modelType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = ''
          File name relative to the model directory.  A relative subdirectory
          is allowed, e.g. `3rd_party/clean_youknow_video.pth` for the
          DeepMosaics restoration model.
        '';
      };

      url = lib.mkOption {
        type = lib.types.str;
        description = "Download URL of the model file.";
      };

      hash = lib.mkOption {
        type = lib.types.str;
        description = "SRI hash of the model file, e.g. `sha256-...`.";
      };
    };
  };

  modelDrvs = map (
    model:
    pkgs.fetchurl {
      name = baseNameOf model.name;
      inherit (model) url hash;
    }
  ) cfg.models;

  modelWeights =
    if cfg.models == [ ] then
      null
    else
      pkgs.linkFarm "lada-model-weights" (
        lib.zipListsWith (model: drv: {
          name = model.name;
          path = drv;
        }) cfg.models modelDrvs
      );

  ladaPackage = cfg.package.override { inherit modelWeights; };
in
{
  options.programs.lada = {
    enable = lib.mkEnableOption "Lada, a video mosaic removal and restoration tool";

    package = lib.mkPackageOption pkgs "lada" { };

    models = lib.mkOption {
      type = lib.types.listOf modelType;
      default = defaultModels;
      description = ''
        Model files fetched with `fetchurl` and linked into a read-only
        directory passed to Lada through `LADA_MODEL_WEIGHTS_DIR`.

        The default contains Lada's CLI defaults: `v4-fast` detection and
        `basicvsrpp-v1.2` restoration (about 84 MiB).  Set to `[ ]` to use
        Lada's default `./model_weights` lookup instead.
      '';
      example = lib.literalExpression ''
        [
          {
            name = "lada_mosaic_detection_model_v4_accurate.pt";
            url = "https://huggingface.co/ladaapp/lada/resolve/main/lada_mosaic_detection_model_v4_accurate.pt?download=true";
            hash = "sha256-wkTX5J2PiOJkuNwV+R+yH1kIrY+28wC3vIhGLQgBvB8=";
          }
          {
            name = "3rd_party/clean_youknow_video.pth";
            url = "https://drive.usercontent.google.com/download?id=1ulct4RhRxQp1v5xwEmUH7xz7AK42Oqlw&export=download&confirm=t";
            hash = "sha256-VkPKKXwTkguP/Tmg2FKW5JRoOmnl6CBNZiZT0kxYJ2Y=";
          }
        ]
      '';
    };

    finalPackage = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      internal = true;
      description = "`package` with `models` linked in as `modelWeights`.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.lada.finalPackage = ladaPackage;
    home.packages = [ cfg.finalPackage ];
  };
}
