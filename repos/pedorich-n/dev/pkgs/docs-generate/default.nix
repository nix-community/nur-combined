{
  pkgs,
  ndg-builder,
  nixosModules ? [ ],
  rev ? "main",
}:
let
  repo = "https://github.com/pedorich-n/nur-packages";
in
ndg-builder.override {
  title = "NUR";
  inputDir = ../../../docs;
  generateSearch = true;
  highlightCode = true;
  optionsDepth = 2;

  rawModules = nixosModules;
  moduleName = "pedorich-n/nur-packages/modules/nixos";
  basePath = ../../../modules/nixos;
  repoPath = "${repo}/blob/${rev}/modules/nixos";

  extraConfig = {
    footer_text = ''Generated with <a href="https://github.com/feel-co/ndg">ndg</a> | Source commit: <a href="${repo}/commit/${rev}">${rev}</a>'';
    sidebar = {
      ordering = "alphabetical";
      options = {
        depth = 2;
        nested = true;
      };
    };
    stylesheet_paths = [
      ../../../docs/assets/custom.css
    ];
  };

  checkModules = false;
  specialArgs = { inherit pkgs; };
  moduleArgs = { inherit pkgs; };
}
