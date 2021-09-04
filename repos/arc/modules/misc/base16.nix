{ lib, config, options, pkgs, ... }: with lib; let
  cfg = config;
  arc = import ../../canon.nix { inherit pkgs; };
  base16-schemes = pkgs.base16-schemes or arc.pkgs.base16-schemes;
  base16 = lib.base16 or arc.lib.base16;
  mapBase16 = f: mapAttrs (_: f) (getAttrs base16.names config // config.aliases);
in {
  imports = [
    base16.types.schemeModule
    base16.types.templateModule
    base16.types.aliasModule
  ];

  options = {
    schemeSource = mkOption {
      type = types.str;
    };
    ansi = mkOption {
      type = base16.shell.shellPaletteType;
    };
    map = mkOption {
      type = types.unspecified;
    };
    templates = mkOption {
      type = types.unspecified;
    };
  };
  config = let
    inherit (pkgs.base16-schemes.${config.schemeSource}.schemes.${config.slug}) data;
    bases = genAttrs base16.names (base: data.${base});
    schemeConfig = mkIf options.schemeSource.isDefined (bases // {
      author = mkIf (data ? author) (mkDefault data.author);
      scheme = mkIf (data ? scheme) (mkDefault data.scheme);
      templateData = mapAttrs (_: mkOptionDefault) (
        removeAttrs data (base16.names ++ [ "author" "scheme" ])
      );
    });
    hashPrefix = b: "#" + b;
    conf = {
      ansi.palette = genAttrs base16.names (name: config.${name}.set);
      templates = mapAttrs (key: template: let
        applied = builtins.trace key (template config.templateData);
        templated = mapAttrs (_: templated: {
          template = applied;
          inherit (templated) path content;
        }) applied.templated;
      in templated // {
        template = applied;
      }) (removeAttrs pkgs.base16-templates [ "override" "overrideDerivation" "recurseForDerivations" ]);
      map = {
        __functor = self: mapBase16;
        hash = mapAttrs (a: mapAttrs (_: hashPrefix)) (removeAttrs config.map [ "__functor" ]);
      } // genAttrs [
        "hex" "rgb" "rgb16" "bgr" "bgr16"
        "rgba" "rgb_" "rgba16" "rgb_16"
        "argb" "_rgb" "argb16" "_rgb16"
        "bgra" "bgr_" "bgra16" "bgr_16"
        "ansiIndex" "ansiStr"
      ] (key: mapBase16 (b: b.${key}));
    } // genAttrs base16.names (base: { config, ... }: {
      options = {
        ansiIndex = mkOption {
          type = types.int;
          default = cfg.ansi.mapping.${base};
        };
        ansiStr = mkOption {
          type = types.str;
          default = toString config.ansiIndex;
        };
      };
    });
  in mkMerge [ conf schemeConfig ];
}
