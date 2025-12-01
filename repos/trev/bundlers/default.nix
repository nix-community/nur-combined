{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
  nixpkgs ? <nixpkgs>,
}:
{
  toDockerStream =
    drv:
    import ./toDockerStream {
      inherit drv pkgs;
    };
}
// import ./goTo/all.nix {
  inherit pkgs;
}
// import ./go/all.nix {
  inherit pkgs;
}
// import ./deno/all.nix {
  inherit pkgs;
}
// import ./docker/all.nix {
  inherit system pkgs nixpkgs;
}
