{
  lib,
  stdenvNoCC,
  buf,
}: let
  buf' = buf;
in
  lib.makeOverridable (
    {
      hash ? "",
      pname,
      buf ? buf',
      ...
    } @ args: let
      args' = builtins.removeAttrs args [
        "hash"
        "pname"
      ];
      hash' =
        if hash != ""
        then {outputHash = hash;}
        else {
          outputHash = "";
          outputHashAlgo = "sha256";
        };
    in
      stdenvNoCC.mkDerivation (
        finalAttrs: (
          args'
          // {
            name = "${pname}-buf-deps";

            nativeBuildInputs = [
              buf
            ];

            installPhase = ''
              runHook preInstall

              export HOME=$(mktemp -d)
              mkdir -p $out

              export BUF_CACHE_DIR="$out"
              buf dep graph

              runHook postInstall
            '';

            dontConfigure = true;
            dontBuild = true;
            dontFixup = true;
            outputHashMode = "recursive";
          }
          // hash'
        )
      )
  )
