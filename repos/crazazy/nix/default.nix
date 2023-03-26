let
  nvfetcher = pkgs.callPackage _sources/generated.nix {};
  mapAttrs = f: attrs: with builtins; listToAttrs (map (x: {name = x; value = f x attrs.${x};}) (attrNames attrs));
  nvsrcs = mapAttrs (k: v: v // {outPath = v.src; name = k;}) nvfetcher;
  niv = import ./sources.nix;
  sources = niv // nvfetcher;
  hmNixos = import niv.home-manager { inherit pkgs; };
  NUR = import niv.NUR { inherit pkgs; };
  pkgs = import niv.nixpkgs {
    overlays = [
      overlay
    ];
  };
  overlay = self: super: {
    inherit niv hmNixos;
  } // NUR;
in
{
  inherit sources pkgs overlay;
  nixos = (import "${niv.nixpkgs}/nixos" { configuration = ../configuration.nix; }).system;
}
