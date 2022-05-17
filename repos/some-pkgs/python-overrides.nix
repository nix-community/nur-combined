{ pkgs, lib }: python-final: python-prev:

{
  accelerate = python-final.callPackage ./pkgs/accelerate.nix { };

  albumentations = python-final.callPackage ./pkgs/albumentations { };

  pyimgui = python-final.callPackage ./pkgs/pyimgui {
    inherit (pkgs.darwin.apple_sdk.frameworks) Cocoa OpenGL CoreVideo IOKit;
  };
  dearpygui = python-final.callPackage ./pkgs/dearpygui {
    inherit (pkgs.darwin.apple_sdk.frameworks) Cocoa OpenGL CoreVideo IOKit;
  };

  ezy-expecttest = python-final.callPackage ./pkgs/ezy-expecttest.nix { };

  opensfm = python-final.callPackage ./pkgs/opensfm { };
  kornia = python-final.callPackage ./pkgs/kornia.nix { };
  gpytorch = python-final.callPackage ./pkgs/gpytorch.nix { };

  instant-ngp = python-final.callPackage ./pkgs/instant-ngp {
    lark = python-final.lark or python-final.lark-parser;
  };

  tensorflow-probability_8_0 = python-final.callPackage ./pkgs/tfp/8.0.nix { };

  gpflow = python-final.callPackage ./pkgs/gpflow.nix { };
  gpflux = python-final.callPackage ./pkgs/gpflux.nix { };
  trieste = python-final.callPackage ./pkgs/trieste.nix { };

  timm = python-final.callPackage ./pkgs/timm.nix { };

  quad-tree-attention = python-final.callPackage ./pkgs/quad-tree-attention { };
  quad-tree-loftr = python-final.quad-tree-attention.feature-matching;

  qudida = python-final.callPackage ./pkgs/qudida { };
}
