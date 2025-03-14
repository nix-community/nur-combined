_:

{
  projectRootFile = "flake.nix";
  settings.excludes = [ "**/_sources/**" ];
  programs = {
    deadnix.enable = true;
    jsonfmt.enable = true;
    nixfmt.enable = true;
    rubocop.enable = true;
    shellcheck.enable = true;
    shfmt = {
      enable = true;
      indent_size = 0;
    };
    statix.enable = true;
    stylua.enable = true;
    yamlfmt.enable = true;
  };
}
