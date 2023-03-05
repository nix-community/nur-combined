{ pkgs, lib }: python-final: python-prev:

{
  accelerate = python-final.callPackage ./pkgs/accelerate.nix { };

  arxiv-py = python-final.callPackage ./pkgs/arxiv-py.nix { };

  albumentations = python-final.callPackage ./pkgs/albumentations { };

  cppimport = python-final.callPackage ./pkgs/cppimport.nix { };

  grobid-client-python = python-final.callPackage ./pkgs/grobid-client-python.nix { };

  imviz = python-final.callPackage ./pkgs/imviz.nix {
    inherit (pkgs.darwin.apple_sdk.frameworks) Cocoa OpenGL CoreVideo IOKit;
  };
  pyimgui = python-final.callPackage ./pkgs/pyimgui {
    inherit (pkgs.darwin.apple_sdk.frameworks) Cocoa OpenGL CoreVideo IOKit;
  };
  dearpygui = python-final.callPackage ./pkgs/dearpygui {
    inherit (pkgs.darwin.apple_sdk.frameworks) Cocoa OpenGL CoreVideo IOKit;
  };

  datasette-render-images = python-final.callPackage ./pkgs/datasette-plugins/datasette-render-images.nix { };

  ezy-expecttest = python-final.callPackage ./pkgs/ezy-expecttest.nix { };

  nvdiffrast = python-final.callPackage ./pkgs/nvdiffrast.nix { };

  opensfm = python-final.callPackage ./pkgs/opensfm { };
  kornia = python-final.callPackage ./pkgs/kornia.nix { };
  gpytorch = python-final.callPackage ./pkgs/gpytorch.nix { };

  instant-ngp = python-final.callPackage ./pkgs/instant-ngp {
    lark = python-final.lark or python-final.lark-parser;
  };

  geomstats = python-final.callPackage ./pkgs/geomstats.nix { };
  geoopt = python-final.callPackage ./pkgs/geoopt.nix { };

  gpflow = python-final.callPackage ./pkgs/gpflow.nix { };
  gpflux = python-final.callPackage ./pkgs/gpflux.nix { };
  trieste = python-final.callPackage ./pkgs/trieste.nix { };

  timm = python-final.callPackage ./pkgs/timm.nix { };

  quad-tree-attention = python-final.callPackage ./pkgs/quad-tree-attention { };
  quad-tree-loftr = python-final.quad-tree-attention.feature-matching;

  qudida = python-final.callPackage ./pkgs/qudida { };
}
