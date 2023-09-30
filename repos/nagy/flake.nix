{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, flake-utils }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (pkgs) lib callPackage;
    in
    {
      lib = lib.extend (final: prev:
        # this extra callPackage call is needed to give
        # the result an `override` ability.
        (callPackage ./lib { }));
      overlays.default =
        import (pkgs.path + "/pkgs/top-level/by-name-overlay.nix")
          ./pkgs/by-name;
      nixosModules = self.lib.modules;
      packages.${system} =
        let
          pkgsWithSelf = import nixpkgs {
            system = pkgs.system;
            overlays = [ self.overlays.default ];
          };
          applied-overlay = self.overlays.default pkgsWithSelf pkgs;
        in
        flake-utils.lib.flattenTree (lib.makeScope pkgs.newScope (scopeself:
          applied-overlay // {
            qemuImages = pkgs.recurseIntoAttrs
              (scopeself.callPackage ./pkgs/qemu-images { });
            python3Packages = pkgs.recurseIntoAttrs
              (pkgs.lib.makeScope pkgs.python3Packages.newScope (self:
                import ./pkgs/python3-packages { inherit (self) callPackage; }));
            lispPackages = pkgs.recurseIntoAttrs {
              dbus = pkgs.callPackage ./pkgs/cl-dbus { };
              cl-opengl = pkgs.callPackage ./pkgs/cl-opengl { };
              cl-raylib = pkgs.callPackage ./pkgs/cl-raylib { };
            };

          }));
    };
}
