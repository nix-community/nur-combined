{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.lada;

  jsonFormat = pkgs.formats.json { };

  models = pkgs.linkFarm "lada-models" (
    map (m: {
      inherit (m) name;
      path = pkgs.fetchurl {
        name = baseNameOf m.name;
        inherit (m) url hash;
      };
    }) cfg.models
  );
in
{
  options.programs.lada = {
    enable = lib.mkEnableOption "Lada";

    package = lib.mkPackageOption pkgs "lada" { };

    models = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = ''
                Path of the model file inside Lada's model directory.

                For most models this is just the file name,
                for example `lada_mosaic_detection_model_v4_fast.pt`.
                DeepMosaics must use `3rd_party/clean_youknow_video.pth`,
                because Lada looks for that model under `3rd_party/`.
              '';
            };

            url = lib.mkOption {
              type = lib.types.str;
              description = ''
                The download URL of the model file.
                Pinned-resolve URLs (e.g. HuggingFace's `/resolve/<commit>/<file>`) are recommended to have a stable hash.
              '';
            };

            hash = lib.mkOption {
              type = lib.types.str;
              example = lib.fakeHash;
              description = ''
                The SRI hash of the model file. Generate it with `nix-prefetch-url <url>`,
                or set this to `lib.fakeHash`, build once and copy the hash from the error message.
              '';
            };
          };
        }
      );
      default = [ ];
      example = lib.literalExpression ''
        [
          {
            name = "lada_mosaic_detection_model_v4_fast.pt";
            url = "https://huggingface.co/ladaapp/lada/resolve/main/lada_mosaic_detection_model_v4_fast.pt";
            hash = "sha256-mmtmDR0+N5fTlRXgiw5y/MWYFfOCefqnpKs3SrLB47Q=";
          }
          {
            name = "lada_mosaic_restoration_model_generic_v1.2.pth";
            url = "https://huggingface.co/ladaapp/lada/resolve/main/lada_mosaic_restoration_model_generic_v1.2.pth";
            hash = "sha256-1AQVJXbOZPtbLzFcAwYnCdrE9fhUiTSGbNAcgjyBBO4=";
          }
        ]
      '';
      description = ''
        Models to download and expose through `LADA_MODEL_WEIGHTS_DIR`.
        The directory is read-only and lives in the Nix store;
        Lada never writes to it.
      '';
    };

    settings = lib.mkOption {
      inherit (jsonFormat) type;
      default = { };
      description = ''
        Lada GUI settings, merged into the writable JSON configuration at
        `$XDG_CONFIG_HOME/lada/lada.conf` during Home Manager activation.

        Lada owns this file and rewrites it when preferences change in the GUI.
        Values declared here take precedence on activation,
        while values not declared here are preserved.
        Set to `{ }` (the default) to leave the configuration file entirely unmanaged.
      '';
      example = lib.literalExpression ''
        {
          color_scheme = "dark";
          device = "cpu";
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.sessionVariables.LADA_MODEL_WEIGHTS_DIR = "${models}";

    # Lada rewrites its config file at startup and when preferences change,
    # so it must not be a read-only symlink into the Nix store.
    # Merge the declared settings into the writable file instead of replacing it.
    home.activation.ladaConfig = lib.mkIf (cfg.settings != { }) (
      lib.hm.dag.entryAfter [ "linkGeneration" ] (
        lib.hm.generators.mkImpureConfigMerger {
          inherit pkgs;
          format = "json";
          empty = "{}";
          jqOperation = "$dynamic + $static";
          path = "${config.xdg.configHome}/lada/lada.conf";
          staticSettings = jsonFormat.generate "lada.conf" cfg.settings;
        }
      )
    );
  };
}
