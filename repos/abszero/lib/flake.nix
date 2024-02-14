{
  description = "Weathercold's utility library";

  inputs.nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";

  outputs = { self, nixpkgs-lib }: {
    lib = import ./. { inherit (nixpkgs-lib) lib; };
  };
}
