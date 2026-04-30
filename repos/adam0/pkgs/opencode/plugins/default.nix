{
  # keep-sorted start
  bun,
  callPackage,
  lib,
  stdenvNoCC,
  # keep-sorted end
}: let
  inherit
    (builtins)
    # keep-sorted start
    mapAttrs
    readDir
    # keep-sorted end
    ;
  inherit
    (lib)
    # keep-sorted start
    filterAttrs
    pipe
    platforms
    # keep-sorted end
    ;

  root = ./.;

  mkOpencodePlugin = args @ {
    # keep-sorted start
    buildCommand ? null,
    dependencyHash ? null,
    dependencyInstallCommand ? "bun install --no-cache --production",
    meta ? {},
    pname,
    src,
    version,
    # keep-sorted end
    ...
  }: let
    deps =
      if dependencyHash == null
      then
        stdenvNoCC.mkDerivation {
          pname = "${pname}-deps";
          inherit version src;

          # keep-sorted start
          dontBuild = true;
          dontFixup = true;
          dontUnpack = true;
          # keep-sorted end

          installPhase = ''
            mkdir -p "$out/node_modules"
          '';
        }
      else
        stdenvNoCC.mkDerivation {
          pname = "${pname}-deps";
          inherit version src;

          nativeBuildInputs = [bun];

          # keep-sorted start
          dontBuild = true;
          dontFixup = true;
          # keep-sorted end

          installPhase = ''
            export HOME="$TMPDIR"

            ${dependencyInstallCommand}

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
        # keep-sorted start
        "buildCommand"
        "dependencyHash"
        "dependencyInstallCommand"
        "meta"
        # keep-sorted end
      ])
      // {
        nativeBuildInputs = [bun] ++ (args.nativeBuildInputs or []);
        dontBuild = true;

        installPhase = ''
          runHook preInstall

          cp -r ${deps}/node_modules ./node_modules

          runHook preBuild
          ${lib.optionalString (buildCommand != null) buildCommand}
          runHook postBuild

          mkdir -p "$out"
          cp -r . "$out/"

          cd "$out"

          runHook postInstall
        '';

        meta =
          meta
          // {
            # keep-sorted start
            description = meta.description or "";
            platforms = meta.platforms or platforms.unix;
            # keep-sorted end
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
