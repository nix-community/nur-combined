let
  f = builtins.getFlake (toString ./.);
  nixpkgs = f.inputs.nixpkgs;
  pkgs = import nixpkgs {
    config.allowUnfree = true;
    config.cudaSupport = true;
    overlays = [ f.overlay ];
  };
in
pkgs.some-pkgs
