{ pkgs, stdenv, lib, callPackage, buildVimPluginFrom2Nix, npm-buildpackage }:

let
  inherit (npm-buildpackage) buildNpmPackage buildYarnPackage;
in self: super: {
  coc-nvim = super.coc-nvim.overrideAttrs (old: let
    deps = buildYarnPackage {
      inherit (old) src;
    };
  in {
    configurePhase = ''
      mkdir -p node_modules
      ln -s ${deps}/node_modules/* node_modules/
      ln -s ${deps}/node_modules/.bin node_modules/
    '';

    buildPhase = ''
      ${pkgs.yarn}/bin/yarn build
    '';
  });

  lslvimazing = super.lslvimazing.overrideAttrs (old: {
    patches = [ ./lslvimazing.patch ];
  });

  markdown-preview-nvim = super.markdown-preview-nvim.overrideAttrs (old: {
    src = buildYarnPackage { inherit (old) src; };
  });

  vim-package-info = super.vim-package-info.overrideAttrs (old: {
    src = buildNpmPackage { inherit (old) src; };
  });
}
