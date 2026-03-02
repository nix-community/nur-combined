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
        for f in ./**; do
          if [[ -f "$f" ]]; then
            ${check.forEach}
          fi
        done
        shopt -u globstar
      ''
    );
  in
  if isDerivation check.src then
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
      src = check.src or ./.;

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
