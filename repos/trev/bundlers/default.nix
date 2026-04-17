{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
let
  libs = import ../libs { inherit system pkgs; };
in
{
  image =
    drv:
    libs.mkImage {
      src = drv;
    };

  appimage =
    drv:
    libs.mkAppImage {
      src = drv;
    };
}
// import ./deno/all.nix {
  inherit pkgs;
}
