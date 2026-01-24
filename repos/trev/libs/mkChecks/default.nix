{ pkgs }:
let
  isDerivation = p: builtins.isAttrs p && p ? type && p.type == "derivation";
in
builtins.mapAttrs (
  name: check:
  if isDerivation check.src then
    check.src.overrideAttrs (
      final: prev: {
        name = name;
        nativeBuildInputs = prev.nativeBuildInputs ++ (check.deps or check.nativeBuildInputs or [ ]);

        dontBuild = true;

        doCheck = true;
        checkPhase = pkgs.lib.strings.concatLines [
          "export HOME=$(mktemp -d)"
          "export TREEFMT_TREE_ROOT=$(pwd)"
          check.script or check.checkPhase
        ];

        installPhase = ''
          echo "#!${pkgs.runtimeShell}" >> $out
          echo "export PATH=${pkgs.lib.makeBinPath final.nativeBuildInputs}:$PATH" >> $out
          echo "${final.checkPhase}" >> $out
          chmod +x $out
        '';

        dontFixup = true;
      }
    )
  else
    pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
      name = name;
      src = check.src or ./.;
      nativeBuildInputs = check.deps or check.nativeBuildInputs or [ ];

      dontConfigure = true;
      dontBuild = true;

      doCheck = true;
      checkPhase = pkgs.lib.strings.concatLines [
        "export HOME=$(mktemp -d)"
        "export TREEFMT_TREE_ROOT=$(pwd)"
        check.script or check.checkPhase
      ];

      installPhase = ''
        echo "#!${pkgs.runtimeShell}" >> $out
        echo "export PATH=${pkgs.lib.makeBinPath finalAttrs.nativeBuildInputs}:$PATH" >> $out
        echo "${finalAttrs.checkPhase}" >> $out
        chmod +x $out
      '';

      dontFixup = true;
    })
)
