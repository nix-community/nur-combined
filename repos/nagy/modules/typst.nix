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
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.typst.withPackages (p: [
        p.modern-cv_0_9_0
        (basic_resume_overrider p.basic-resume_0_2_8)
        (letter_pro_overrider p.letter-pro_3_0_0)
      ]);
    };
  };

  config = {
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
