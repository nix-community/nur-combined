{
  perSystem = { pkgs, ... }: { packages = import ./. { inherit pkgs; }; };
  flake.overlays = rec {
    abszero = final: _: import ./. { pkgs = final; };
    default = abszero;
  };
}
