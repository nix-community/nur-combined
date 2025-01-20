{pkgs, ...}: {
  packages = with pkgs; [
    # nix tooling
    alejandra
    nixd

    (rWrapper.override {
      packages = with pkgs.rPackages; [
        rqdatatable
        rstudioapi
        tibble
      ];
    })
  ];

  languages.rust.enable = true;
  languages.nix.enable = true;

  git-hooks.hooks = {
    alejandra.enable = true;
  };
}
