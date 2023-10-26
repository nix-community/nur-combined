{ config, pkgs, lib, ... }: with lib; let
  cfg = config.programs.page;
  args =
    optionals cfg.openLines.enable [ "-O" (toString (- cfg.openLines.promptHeight)) ]
    ++ optionals (cfg.queryLines != 0) [ "-q" (toString cfg.queryLines) ];
  batWrapper = pkgs.writeShellScriptBin "bat" ''
    ARGS=()
    for arg in "$@"; do
      if [[ $arg = --language=* ]]; then
        LANG=$(cut -d= -f2 <<<"$arg")
        ARGS+=("--file-name=stdin.$LANG")
      elif [[ $arg = --plain ]]; then
        ARGS+=("--style=plain")
      else
        ARGS+=("$arg")
      fi
    done
    if [[ -n $PAGE_BAT_LANG ]]; then
      ARGS+=("--language=$PAGE_BAT_LANG")
    fi
    exec ${getExe config.programs.bat.package or pkgs.bat} "''${ARGS[@]}"
  '';
  pager = pkgs.writeShellScriptBin "page" ''
    PAGE_NVIM_ARGS=(${escapeShellArgs args} "$@")
    ${cfg.wrapper.setup}
    exec ${cfg.package}/bin/page "''${PAGE_NVIM_ARGS[@]}"
  '';
in {
  options.programs.page = {
    enable = mkEnableOption "page";
    package = mkOption {
      type = types.package;
      default = pkgs.page;
      defaultText = literalExpression "pkgs.page";
    };
    finalPackage = mkOption {
      type = types.package;
      default = pager;
      defaultText = literalExpression "wrapped config.programs.page.package";
    };

    wrapper = {
      setup = mkOption {
        type = types.lines;
      };
      bat = {
        enable = mkEnableOption "bat wrapper" // {
          default = config.programs.bat.enable;
        };
        package = mkOption {
          type = types.package;
          default = batWrapper;
        };
      };
    };

    manPager = mkEnableOption "page as MANPAGER";

    queryLines = mkOption {
      type = types.ints.between 0 100000;
      default = 0;
    };
    openLines = {
      enable = mkEnableOption "skip pager if output is smaller than terminal height";
      promptHeight = mkOption {
        type = types.int;
        default = 1;
      };
    };
  };
  config = {
    programs.page = {
      wrapper.setup = mkMerge [
        (mkBefore ''export PAGE_NVIM=1'')
        (mkIf cfg.wrapper.bat.enable ''export PATH=${cfg.wrapper.bat.package}/bin:$PATH'')
      ];
    };
    programs.bat.enable = mkIf (cfg.enable && cfg.openLines.enable) (mkOverride 1450 true);
    home = mkIf cfg.enable {
      packages = singleton cfg.finalPackage;
      sessionVariables = mkMerge [ {
        PAGER = "page";
      } (mkIf cfg.manPager {
        MANPAGER = "page -t man";
      }) ];
    };
  };
}
