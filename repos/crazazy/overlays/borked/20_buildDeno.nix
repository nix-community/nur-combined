# builds a deno project from a import file
self: super: let
   inherit (builtins) fetchurl fromJSON pathExists readFile seq toJSON toFile;
   inherit (super) stdenv deno lib;
   # human-readable version of assert
   test = x: errorMsg: x || throw errorMsg;
   inherit (lib) mapAttrs;
in
   {
      buildDeno = { name, src, entryFile ? "main.ts", version ? "" }: let
         hasImportMap = test (pathExists (src + "/import-map.json")) ''
            your project is missing an import map (import-map.json)
            we use an import map to easily determine which dependencies you miss before including them in the build
         '';
         importFile = seq hasImportMap (readFile (src + "/import-map.json"));
         imports = (fromJSON importFile).imports;
         newImports.imports = mapAttrs (k: v: "file://" + toString (fetchurl v)) imports;
         newImportFile = toFile "import-map.json" (toJSON newImports);
      in
      stdenv.mkDerivation {
         inherit name src version;
         pname = name;
         configurePhase = ''
            rm import-map.json
            cp ${newImportFile} ./import-map.json
         '';
         # TODO: when import maps hit stable, remove the unstable flag
         buildPhase = ''
            mkdir -p $out/share
            DENO_DIR=$PWD ${deno}/bin/deno bundle --unstable ${ entryFile } --import-map ./import-map.json $out/share/app.bundle.js
            rm -rf $DENO_DIR
         '';
         installPhase = ''
            mkdir -p $out/bin
            cat > $out/bin/${name} << EOF
            #!/bin/sh
            DENO_DIR=$(mktemp -d)
            ${deno}/bin/deno run --allow-all $out/share/app.bundle.js
            EOF
         '';
      };
   }

