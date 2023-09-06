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
        lib.composeManyExtensions (self.lib.importNixFiles ./overlays);
      nixosModules = self.lib.modules;
      packages.${system} = flake-utils.lib.flattenTree
        (lib.makeScope pkgs.newScope (scopeself:
          {
            qemuImages = pkgs.recurseIntoAttrs
              (scopeself.callPackage ./pkgs/qemu-images { });
            python3Packages = pkgs.recurseIntoAttrs
              (self.lib.makeScope pkgs.python3Packages.newScope (self:
                import ./pkgs/python3-packages {
                  inherit (self) callPackage;
                }));
            lispPackages = pkgs.recurseIntoAttrs {
              vacietis = pkgs.callPackage ./pkgs/vacietis { };
              dbus = pkgs.callPackage ./pkgs/cl-dbus { };
              cl-opengl = pkgs.callPackage ./pkgs/cl-opengl { };
              cl-raylib = pkgs.callPackage ./pkgs/cl-raylib { };
              s-dot = pkgs.callPackage ./pkgs/s-dot { };
              s-dot2 = pkgs.callPackage ./pkgs/s-dot2 { };
              tinmop = pkgs.callPackage ./pkgs/tinmop { };
            };

            ksv = scopeself.callPackage ./pkgs/ksv { };

            qr2text = scopeself.callPackage ./pkgs/qr2text { };

            urlp = scopeself.callPackage ./pkgs/urlp { };
          } // (self.lib.callNixFiles scopeself.callPackage ./pkgs)));
    };
}
