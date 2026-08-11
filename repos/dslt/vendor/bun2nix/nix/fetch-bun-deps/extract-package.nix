{ lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib) mkOption types;
in
{
  options.perSystem = mkPerSystemOption {
    options.fetchBunDeps.extractPackage = mkOption {
      description = ''
        Generic package extraction script for use in fetchBunDeps.

        If the package is a tarball, extract it,
        otherwise make a copy of the input directory in $out
      '';
      type = types.package;
    };
  };

  config.perSystem =
    {
      pkgs,
      ...
    }:
    {
      fetchBunDeps.extractPackage = pkgs.writeShellApplication {
        name = "extract-bun-package";
        runtimeInputs = [
          pkgs.libarchive
        ];
        text = ''
          throw_usage () {
              echo "Missing required flags"
              echo "Usage: --pkg <pkg> --out <out>"
              exit 1
          }

          pkg=""
          out=""

          while [ "$#" -gt 0 ]; do
            case "$1" in
              --package)
                shift
                pkg="$1"
                ;;
              --out)
                shift
                out="$1"
                ;;
              --package=* )
                pkg="''${1#--package=}"
                ;;
              --out=* )
                out="''${1#--out=}"
                ;;
              -*)
                echo "Unknown option: $1"
                throw_usage
                ;;
              *)
                # ignore stray positional args or treat as error:
                echo "Unexpected positional arg: $1"
                throw_usage
                ;;
            esac
            shift
          done

          if [ -z "$pkg" ] || [ -z "$out" ]; then
            throw_usage
          fi

          mkdir -p "$out"

          if [[ "$pkg" = *.tgz ]]; then
            bsdtar --extract \
              --file "$pkg" \
              --directory "$out" \
              --strip-components=1 \
              --no-same-owner \
              --no-same-permissions
          else
            cp -r "$pkg/." "$out"
          fi

          chmod -R u+rwx "$out"
        '';
      };
    };
}
