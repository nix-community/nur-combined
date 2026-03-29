{
  lib,
  runtimeShell,
  stdenvNoCC,
}:
let
  isDerivation = p: builtins.isAttrs p && p ? type && p.type == "derivation";
in
builtins.mapAttrs (
  name: check:
  let
    checkPhase = lib.strings.concatLines (
      [
        "runHook preCheck"
        "export HOME=$(mktemp -d)"
        "export TREEFMT_TREE_ROOT=$(pwd)"
      ]
      ++ lib.optional (check ? checkPhase) check.checkPhase
      ++ lib.optional (check ? script) check.script
      ++ lib.optional (check ? forEach) ''
        shopt -s globstar

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

        shopt -u globstar
      ''
      ++ [ "runHook postCheck" ]
    );
  in
  if check ? src && isDerivation check.src then
    check.src.overrideAttrs (
      final: prev: {
        inherit name checkPhase;

        nativeCheckInputs =
          prev.nativeCheckInputs ++ (check.deps or check.packages or check.nativeBuildInputs or [ ]);

        doCheck = true;
      }
    )
  else
    stdenvNoCC.mkDerivation (finalAttrs: {
      inherit name checkPhase;

      src =
        if check ? root then
          lib.fileset.toSource {
            root = check.root;
            fileset =
              let
                set =
                  if check ? fileset then
                    check.fileset
                  else if check ? filter then
                    lib.fileset.fileFilter check.filter check.root
                  else
                    check.root;
              in
              if check ? ignore then
                lib.fileset.difference set (
                  if builtins.isList check.ignore then lib.fileset.unions check.ignore else check.ignore
                )
              else
                set;
          }
        else
          check.src;

      nativeBuildInputs = check.deps or check.packages or check.nativeBuildInputs or [ ];

      dontConfigure = true;
      dontBuild = true;
      doCheck = true;

      installPhase = ''
        echo "#!${runtimeShell}" >> $out
        echo "export PATH=${lib.makeBinPath finalAttrs.nativeBuildInputs}:$PATH" >> $out
        echo "${finalAttrs.checkPhase}" >> $out
        chmod +x $out
      '';

      dontFixup = true;
    })
)
