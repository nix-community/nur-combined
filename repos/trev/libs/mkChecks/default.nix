{
  lib,
  stdenvNoCC,
}:

let
  isDerivation = p: builtins.isAttrs p && p ? type && p.type == "derivation";
in

builtins.mapAttrs (
  name: check:
  let
    nativeCheckInputs =
      check.deps or check.packages or check.nativeBuildInputs or check.nativeCheckInputs or [ ];

    checkPhase = lib.strings.concatLines (
      [
        "runHook preCheck"
        "export HOME=$(mktemp -d)"
        "export TREEFMT_TREE_ROOT=$(pwd)"
        (check.script or check.checkPhase or "")
      ]
      ++ lib.optional (check ? forEach) ''
        shopt -s globstar dotglob

        for_each() {
          local file="$1"
          ${check.forEach}
        }

        for file in ./**; do
          if [[ -f "$file" ]]; then
            echo "Checking $(basename "$file")"
            for_each "$(realpath "$file")"
          fi
        done

        shopt -u globstar dotglob
      ''
      ++ [ "runHook postCheck" ]
    );
  in

  if check ? src && isDerivation check.src then
    check.src.overrideAttrs (
      final: prev: {
        inherit name checkPhase;

        nativeCheckInputs = (prev.nativeCheckInputs or [ ]) ++ nativeCheckInputs;
        doCheck = true;
      }
    )
  else
    stdenvNoCC.mkDerivation (finalAttrs: {
      inherit name nativeCheckInputs checkPhase;

      src =
        if check ? root then
          lib.fileset.toSource {
            root = check.root;
            fileset =
              let
                start = check.files or check.fileset or check.root;
                files = if builtins.isList start then lib.fileset.unions start else lib.fileset.fromSource start;

                filtered =
                  if check ? filter then
                    lib.fileset.intersection files (lib.fileset.fileFilter check.filter check.root)
                  else
                    files;

                ignored =
                  if check ? ignore then
                    lib.fileset.difference filtered (
                      if builtins.isList check.ignore then lib.fileset.unions check.ignore else check.ignore
                    )
                  else
                    filtered;

                included =
                  if check ? include then
                    lib.fileset.union ignored (
                      if builtins.isList check.include then lib.fileset.unions check.include else check.include
                    )
                  else
                    ignored;
              in
              included;
          }
        else
          check.src;

      dontConfigure = true;
      dontBuild = true;
      doCheck = true;
      installPhase = "touch $out";
      dontFixup = true;
    })
)
