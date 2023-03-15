{ self, pkgs, system }: {
  src = self;
  hooks = {
    nixfmt.enable = true;
    statix.enable = false;
    prettier-write = {
      enable = true;
      name = "Prettier Write";
      entry = "${pkgs.nodePackages.prettier}/bin/prettier --write .";
      files = "\\.(js|ts|jsx|tsx|json|yml|yaml)$";
      language = "system";
    };

    statix-write = {
      enable = true;
      name = "Statix Write";
      entry = "${pkgs.statix}/bin/statix fix";
      language = "system";
      pass_filenames = false;
    };

    trufflehog-verified = {
      enable = true;
      name = "Trufflehog Search";
      entry =
        "${pkgs.trufflehog}/bin/trufflehog git file://. --since-commit HEAD --only-verified --fail";
      language = "system";
      pass_filenames = false;
    };

    trufflehog-regex = {
      enable = true;
      name = "Trufflehog Regex Search";
      entry =
        "${pkgs.trufflehog}/bin/trufflehog git file://. --since-commit HEAD --config .trufflehog/config.yaml --fail --no-verification -x ./.trufflehog/path_exclusions";
      language = "system";
      pass_filenames = false;
    };
  };
}
