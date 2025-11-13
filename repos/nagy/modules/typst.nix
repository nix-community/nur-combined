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
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.typst.withPackages (p: [
        p.modern-cv_0_9_0
        p.basic-resume_0_2_8
        p.letter-pro_3_0_0
      ]))
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
