{
  lib,
  callPackage,
  stdenvNoCC,
  bun,
}: let
  inherit
    (builtins)
    readDir
    mapAttrs
    ;
  inherit
    (lib)
    filterAttrs
    pipe
    platforms
    ;

  root = ./.;

  mkOpencodePlugin = args @ {
    pname,
    version,
    src,
    dependencyHash ? null,
    meta ? {},
    ...
  }: let
    deps =
      if dependencyHash == null
      then
        stdenvNoCC.mkDerivation {
          pname = "${pname}-deps";
          inherit version src;

          dontBuild = true;
          dontFixup = true;
          dontUnpack = true;

          installPhase = ''
            mkdir -p "$out/node_modules"
          '';
        }
      else
        stdenvNoCC.mkDerivation {
          pname = "${pname}-deps";
          inherit version src;

          nativeBuildInputs = [bun];

          dontBuild = true;
          dontFixup = true;

          installPhase = ''
            export HOME="$TMPDIR"

            bun install --no-cache --production

            mkdir -p "$out"
            cp -r node_modules "$out/"
          '';

          outputHash = dependencyHash;
          outputHashAlgo = "sha256";
          outputHashMode = "recursive";
        };
  in
    stdenvNoCC.mkDerivation (
      (removeAttrs args [
        "dependencyHash"
        "meta"
      ])
      // {
        nativeBuildInputs = [bun] ++ (args.nativeBuildInputs or []);
        dontBuild = true;

        installPhase = ''
          runHook preInstall

          cp -r ${deps}/node_modules ./node_modules

          mkdir -p "$out"
          cp -r . "$out/"

          runHook postInstall
        '';

        meta =
          meta
          // {
            description = meta.description or "";
            platforms = meta.platforms or platforms.unix;
          };
      }
    );

  call = name: callPackage (root + "/${name}") {inherit mkOpencodePlugin;};
in
  pipe root [
    readDir
    (filterAttrs (_: type: type == "directory"))
    (mapAttrs (name: _: call name))
  ]
  // {
    inherit mkOpencodePlugin;
  }
