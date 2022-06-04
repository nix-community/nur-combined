{ config, pkgs, lib, ... }: with lib; let
  cfg = config.programs.page;
  args = escapeShellArgs (
    optionals cfg.openLines.enable [ "-O" (toString (- cfg.openLines.promptHeight)) ]
    ++ optionals (cfg.queryLines != 0) [ "-q" (toString cfg.queryLines) ]
  );
  pager = pkgs.writeShellScriptBin "page" (concatStringsSep "\n" (
    [
      ''export PAGE_NVIM=1''
      ''exec ${cfg.package}/bin/page ${args} "$@"''
    ]
  ));
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

    manPager = mkEnableOption "page as MANPAGER";

    queryLines = mkOption {
      type = types.ints.between 0 100000;
      default = 0;
    };
    openLines = {
      enable = mkEnableOption "skip pager if output is smaller than terminal height"; # NOTE: requires arc.packages.page-develop
      promptHeight = mkOption {
        type = types.int;
        default = 1;
      };
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = singleton cfg.finalPackage;
      sessionVariables = mkMerge [ {
        PAGER = "page";
      } (mkIf cfg.manPager {
        MANPAGER = "page";
      }) ];
    };
  };
}
