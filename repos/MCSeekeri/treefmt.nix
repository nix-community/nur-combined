{
  projectRootFile = "flake.nix";

  programs = {
    nixfmt = {
      enable = true;
      strict = true;
    };
    deadnix.enable = true;
    statix.enable = true;

    dos2unix.enable = true;
    keep-sorted.enable = true;
    autocorrect = {
      enable = true;
      settings = {
        rules = {
          space-word = "error";
          space-punctuation = "error";
          space-bracket = "error";
          space-backticks = "error";
          space-dash = "error";
          space-dollar = "error";
          fullwidth = "error";
          no-space-fullwidth = "error";
          halfwidth-word = "error";
          halfwidth-punctuation = "error";
          spellcheck = "error";
        };
        context.codeblock = "error";
      };
    };
    sizelint = {
      enable = true;
      failOnWarn = true;
    };
    mdformat = {
      enable = true;
      plugins = ps: [ ps.mdformat-gfm ];
      settings = {
        wrap = "keep";
        number = true;
        end-of-line = "lf";
      };
    };
  };
}
