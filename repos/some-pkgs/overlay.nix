final: prev:
let
  lib' = prev.lib;
  inherit (import ./lib/extend-lib.nix prev.lib) lib;

  inherit (lib) readByName autocallByName;

  toplevelFiles = readByName ./pkgs/by-name;
  pythonFiles = readByName ./python-packages/by-name;
in
{
  inherit lib;

  pythonPackagesExtensions = (prev.pythonPackagesExtensions or [ ]) ++ [
    (py-final: py-prev:
      let
        autocalled = (autocallByName py-final ./python-packages/by-name);
        extra = {
          cppcolormap = py-final.toPythonModule (final.some-pkgs.cppcolormap.override {
            enablePython = true;
            python3Packages = py-final;
          });

          faiss = py-final.toPythonModule (final.faiss.override {
            pythonSupport = true;
            pythonPackages = py-final;
          });

          some-pkgs-faiss = py-final.toPythonModule (final.some-pkgs.faiss.override {
            pythonSupport = true;
            pythonPackages = py-final;
          });

          instant-ngp = py-final.callPackage ./python-packages/by-name/in/instant-ngp/package.nix {
            lark = py-final.lark or py-final.lark-parser;
          };

          quad-tree-loftr = py-final.quad-tree-attention.feature-matching;
        };
      in
      autocalled // extra // {
        some-pkgs-py = lib'.mapAttrs (name: _: py-final.${name}) (autocalled // extra);
      })
  ];

  # Some things we want to expose even outside some-pkgs namespace:
  inherit (final.some-pkgs) faiss;

  some-util = final.callPackage ./some-util { };

  some-pkgs =
    (autocallByName final.some-pkgs ./pkgs/by-name) //
    {
      some-pkgs-py = prev.recurseIntoAttrs final.python3Packages.some-pkgs-py;
      callPackage = final.lib.callPackageWith (final // final.some-pkgs);

      faiss = final.callPackage ./pkgs/by-name/fa/faiss {
        pythonPackages = final.python3Packages;
        swig = final.swig4;
      };

      fetchdata = { urls, hash, ... }: final.fetchurl {
        inherit urls hash;
        recursiveHash = true;
        downloadToTemp = true;
        postFetch = ''
          mkdir -p "$out/data"
          mv "$downloadedFile" "$out/data/$name"
        '';
      };
    };

  some-datasets = import ./datasets { lib = final.lib; pkgs = final; };

} // lib'.optionals (lib'.versionOlder lib'.version "23.11") {
  # 2023-08-28: NUR still uses the 23.05 channel which doesen't handle pythonPackagesExtensions
  python3 =
    let
      self = prev.python3.override {
        packageOverrides = lib'.composeManyExtensions final.pythonPackagesExtensions;
        inherit self;
      };
    in
    self;
  python3Packages = final.python3.pkgs;
}
