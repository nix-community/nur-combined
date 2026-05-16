_:

{
  files = {
    ".github/actionlint.yaml".yaml = {
      paths = {
        ".github/workflows/**/*.lock.yml".ignore = [ ".*" ];
        ".github/workflows/agentics-maintenance.yml".ignore = [ ".*" ];
      };
    };
    ".markdownlint.yaml".yaml = {
      MD013 = false;
    };
    ".markdownlintignore".text = ''
      .github/workflows/
    '';
    ".yamllint.yaml".yaml = {
      extends = "default";
      rules = {
        document-start = "disable";
        truthy = "disable";
        comments = "disable";
        line-length.max = 120;
      };
      ignore = [ ".github/workflows/" ];
    };
    ".yamlfmt.yaml".yaml = {
      formatter = {
        type = "basic";
        line_ending = "lf";
        max_line_length = 120;
        trim_trailing_whitespace = true;
        eof_newline = true;
        force_array_style = "block";
      };
    };
    "statix.toml".toml = {
      ignore = [ ".devenv" ];
    };
  };

  languages = {
    nix.enable = true;
    shell.enable = true;
  };

  git-hooks.hooks = {
    mdsh.enable = true;
    shellcheck.enable = true;
    action-validator.enable = true;
    actionlint.enable = true;
    nixfmt.enable = true;
    check-added-large-files.enable = true;
    check-case-conflicts.enable = true;
    check-json.enable = true;
    check-merge-conflicts.enable = true;
    check-vcs-permalinks.enable = true;
    check-symlinks.enable = true;
    check-yaml.enable = true;
    deadnix.enable = true;
    detect-private-keys.enable = true;
    markdownlint.enable = true;
    mixed-line-endings.enable = true;
    yamlfmt.enable = true;
    statix.enable = true;
    trufflehog.enable = true;
    yamllint.enable = true;
    nixf-diagnose.enable = true;
  };

  treefmt = {
    enable = true;
    config.programs = {
      nixfmt.enable = true;
      actionlint.enable = true;
      jsonfmt.enable = true;
      nixf-diagnose.enable = true;
      deadnix.enable = true;
      statix.enable = true;
      yamlfmt.enable = true;
    };
  };
}
