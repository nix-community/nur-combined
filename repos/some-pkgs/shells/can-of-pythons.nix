let
  some-pkgs = builtins.getFlake "git+file://${builtins.unsafeDiscardStringContext (toString ./..)}";
  pkgs = import (builtins.getFlake github:NixOS/nixpkgs/4b780d230fc31780445a607a27015caaca699790) {
    overlays = [ some-pkgs.overlay ];
    config.cudaSupport = true;
    config.cudaCapabilities = [ "8.6" ];
    config.allowUnfree = true;
  };
  py = pkgs.python3.withPackages (ps: with ps; [
    # cppimport
    pyimgui
    # pytest
    # setuptools
    # nvdiffrast
    # torch
    # imageio
    # parallelformers
    # albumentations
    mask-face-gan
    # stylegan2
    # rosalinity_stylegan2
    face-attribute-editing-stylegan3
    (face-attribute-editing-stylegan3.override { moduleName = null; })
  ]);
in
with pkgs;
mkShell.override { stdenv = cudaPackages.backendStdenv; } {
  name = "can-of-pythons";
  packages = [
    py
    ninja
  ];
  CUDA_HOME = cudaPackages.cudatoolkit;
  shellHook = ''
    addToSearchPath LIBRARY_PATH ${cudaPackages.cuda_cudart}/lib
  '';
}
