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
  letter_pro_overrider =
    package:
    package.overrideAttrs {
      src = pkgs.fetchFromGitHub {
        owner = "nagy";
        repo = "typst-letter-pro";
        rev = "bacc123b632e7ac48630775ee896b40fa3f14e27";
        hash = "sha256-Mn8uuya0ufnR7T5v+ajTVYOAaN6p2EZmklOf4bm8Z44=";
      };
      # per default no folding marks
      postPatch = ''
        substituteInPlace src/lib.typ \
          --replace-fail 'folding-marks: true,' 'folding-marks: false,' \
          --replace-fail 'hole-mark: true,' 'hole-mark: false,'
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
