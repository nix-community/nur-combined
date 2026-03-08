{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nagy.typst;
  basic_resume_overrider =
    package:
    package.overrideAttrs {
      # postPatch = ''
      #   substituteInPlace src/resume.typ \
      #     --replace-fail '[= #(author)]' ""
      # '';
      postPatch = ''
        substituteInPlace src/resume.typ \
          --replace-fail ': orcid-icon' ": orcid-icon, github-icon, email-icon" \
          --replace-fail '(email, ' "(email, prefix: [#email-icon()], " \
          --replace-fail '(github, ' "(github, prefix: [#github-icon()], " \
          --replace-fail 'github: "",' 'github: "", dob: "",' \
          --replace-fail '//orcid.org/"),' '//orcid.org/"), contact-item(dob),' \
          --replace-fail 'show link: underline' "// "
      '';
    };
in
{
  options.nagy.typst = {
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.typst.withPackages (p: [
        p.modern-cv_0_9_0
        (basic_resume_overrider p.basic-resume_0_2_8)
        # (letter_pro_overrider p.letter-pro_3_0_0)
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
