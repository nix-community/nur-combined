{
  imports = [
    ./modules/treefmt/checkmake.nix
  ];

  projectRootFile = "flake.nix";

  programs.checkmake = {
    enable = true;
    settings = {
      maxbodylength.maxBodyLength = 10;
    };
  };
  programs.keep-sorted.enable = true;
  programs.mdformat = {
    enable = true;
    settings = {
      number = true;
      wrap = 80;
    };
  };
  programs.nixf-diagnose.enable = true;
  programs.nixfmt.enable = true;
  programs.statix.enable = true;
  programs.typos = {
    enable = true;
    # configFile = builtins.toString ./.typos.toml;
  };
  programs.yamlfmt = {
    enable = true;
    settings = {
      gitignore_excludes = true;
      formatter = {
        type = "basic";
        indentless_arrays = true;
        retain_line_breaks_single = true;
        scan_folded_as_literal = true;
        trim_trailing_whitespace = true;
      };
    };
  };
  settings.global.excludes = [
    ".direnv"
    "NUR"
    "tmp"
  ];
}
