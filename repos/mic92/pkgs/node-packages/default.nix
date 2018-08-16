{ pkgs, system, nodejs }:

let
  nodePackages = import ./composition.nix {
    inherit pkgs system nodejs;
  };
in
(nodePackages // {
  listr-verbose-renderer = nodePackages.listr-verbose-renderer.override (oldAttrs: {
    preRebuild = ''
        echo fail
        exit 1
    '';
  });
  listr = nodePackages.listr.override (oldAttrs: {
    preRebuild = ''
        echo fail
        exit 1
    '';
  });
})
