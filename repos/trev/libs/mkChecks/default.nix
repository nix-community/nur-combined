{ pkgs }:
let
  isDerivation = p: builtins.isAttrs p && p ? type && p.type == "derivation";
in
builtins.mapAttrs (
  name: check:
  let
    checkPhase = pkgs.lib.strings.concatLines (
      [
        "export HOME=$(mktemp -d)"
        "export TREEFMT_TREE_ROOT=$(pwd)"
      ]
      ++ pkgs.lib.optional (check ? checkPhase) check.checkPhase
      ++ pkgs.lib.optional (check ? script) check.script
      ++ pkgs.lib.optional (check ? forEach) ''
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
    );
  in
  if check ? src && isDerivation check.src then
    check.src.overrideAttrs (
      final: prev: {
        name = name;

        nativeBuildInputs = prev.nativeBuildInputs ++ (check.deps or check.nativeBuildInputs or [ ]); # build-time dependencies
        buildInputs = prev.buildInputs ++ (check.buildInputs or [ ]); # run-time dependencies

        doCheck = true;
        inherit checkPhase;
      }
    )
  else
    pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
      name = name;
      src =
        if check ? root then
          pkgs.lib.fileset.toSource {
            root = check.root;
            fileset =
              let
                set =
                  if check ? fileset then
                    check.fileset
                  else if check ? filter then
                    pkgs.lib.fileset.fileFilter check.filter check.root
                  else
                    check.root;
              in
              if check ? ignore then
                pkgs.lib.fileset.difference set (
                  if builtins.isList check.ignore then pkgs.lib.fileset.unions check.ignore else check.ignore
                )
              else
                set;
          }
        else
          check.src;

      nativeBuildInputs = check.deps or check.nativeBuildInputs or [ ]; # build-time dependencies
      buildInputs = check.buildInputs or [ ]; # run-time dependencies

      dontConfigure = true;
      dontBuild = true;

      doCheck = true;
      inherit checkPhase;

      installPhase = ''
        echo "#!${pkgs.runtimeShell}" >> $out
        echo "export PATH=${pkgs.lib.makeBinPath finalAttrs.buildInputs}:$PATH" >> $out
        echo "${finalAttrs.checkPhase}" >> $out
        chmod +x $out
      '';

      dontFixup = true;
    })
)
