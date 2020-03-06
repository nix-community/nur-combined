import (import ./sources.nix).nixpkgs {
  overlays = [
    (import ../overlay.nix)
    (self: super: {
      inherit (import (import ./sources.nix).niv { pkgs = super; }) niv;
    })
  ];
}
