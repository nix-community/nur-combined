{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nagy.typst;
in
{
  options.nagy.typst = {
    enable = lib.mkEnableOption "typst config";

    package = lib.mkOption {
      type = lib.types.package;
      default = (
        pkgs.typst.withPackages (p: [
          p.modern-cv_0_9_0
          p.basic-resume_0_2_8
          p.letter-pro_3_0_0
        ])
      );
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
      pkgs.typstyle
    ];

    fonts = {
      packages = [
        # for typst letters
        pkgs.source-sans-pro
      ];
    };
  };
}
