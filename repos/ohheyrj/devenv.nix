
{ pkgs, lib, config, ... }: {

  packages = [
    pkgs.nvfetcher
    pkgs.trufflehog
    pkgs.gitleaks
  ];

  git-hooks.hooks = {
    gitleaks = {
      enable = true;
      name = "Detect hardcoded secrets";
      description = "Detect hardcoded secrets using Gitleaks";
      entry = "gitleaks git --pre-commit --redact --staged --verbose";
      language = "golang";
      pass_filenames = false;
    };
  };
}

