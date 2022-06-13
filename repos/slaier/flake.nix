{
  description = "My personal NUR repository";
  inputs.nixos.url = "github:NixOS/nixpkgs/nixos-22.05";
  outputs = { self, nixos }:
    let
      inherit (nixos.lib.attrsets) filterAttrs genAttrs;
      inherit (nixos.lib.trivial) flip pipe;

      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: genAttrs systems (system:
        let
          pkgs = import nixos { inherit system; };
        in
        f system pkgs);
    in
    {
      packages = forAllSystems (system: pkgs: pipe
        (import ./default.nix { inherit pkgs; }) [
        # Remove non–package attributes.
        (flip builtins.removeAttrs [ "lib" "modules" "overlays" ])
        # Remove packages not compatible with this system.
        (filterAttrs (attr: drv: drv ? meta.platforms -> builtins.elem system drv.meta.platforms))
      ]);
      formatter = forAllSystems (system: pkgs: pkgs.nixpkgs-fmt);
    };
}
