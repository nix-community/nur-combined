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
          touch $out
        '';

        dontFixup = true;
      }
    )
  else
    pkgs.stdenvNoCC.mkDerivation {
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
        touch $out
      '';

      dontFixup = true;
    }
)
