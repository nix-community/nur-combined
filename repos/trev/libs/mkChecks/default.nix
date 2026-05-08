{
  lib,
  stdenvNoCC,
}:

builtins.mapAttrs (
  name: check:
  if lib.isDerivation check then
    check.overrideAttrs {
      doCheck = true;
    }
  else
    let
      nativeCheckInputs = check.packages or [ ];

      checkScript =
        if check ? forEach || builtins.match ".*\\$file.*" (check.script or "") != null then
          ''
            for_each() {
              local file="$1"
              ${check.forEach or check.script}
            }

            for file in ./**; do
              if [[ -f "$file" ]]; then
                echo "checking $file"
                for_each "$(realpath "$file")"
              fi
            done
          ''
        else
          check.script or "";

      checkPhase = ''
        runHook preCheck

        export HOME=$(mktemp -d)
        export TREEFMT_TREE_ROOT=$(pwd)
        shopt -s globstar dotglob

        ${checkScript}

        shopt -u globstar dotglob
        runHook postCheck
      '';

      extraAttrs = removeAttrs check [
        "root"
        "files"
        "filter"
        "ignore"
        "include"
        "packages"
        "script"
        "forEach"
      ];
    in

    if check ? src && lib.isDerivation check.src then
      check.src.overrideAttrs (
        _: prev: {
          inherit name checkPhase;

          nativeCheckInputs = (prev.nativeCheckInputs or [ ]) ++ nativeCheckInputs;
          doCheck = true;
        }
      )
    else
      stdenvNoCC.mkDerivation (
        extraAttrs
        // {
          inherit name checkPhase nativeCheckInputs;

          src =
            if check ? root then
              lib.fileset.toSource {
                root = check.root;
                fileset =
                  let
                    start = check.files or check.fileset or check.root;

                    files = if builtins.isList start then lib.fileset.unions start else start;

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

          dontBuild = true;
          doCheck = true;
          installPhase = "touch $out";
          dontFixup = true;
        }
      )
)
