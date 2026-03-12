{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
{
  docker =
    drv:
    import ./docker {
      inherit drv pkgs;
    };

  docker-stream =
    drv:
    import ./docker/stream.nix {
      inherit drv pkgs;
    };

  cross =
    drv:
    import ./cross {
      inherit drv pkgs;
    };
}
// import ./deno/all.nix {
  inherit pkgs;
}
