{ pkgs }:
{
  compile = pkgs.lib.makeOverridable (
    {
      pkg,
      target ? "x86_64-unknown-linux-gnu",
      allow-read ? true,
      allow-write ? true,
      allow-net ? true,
      allow-env ? true,
      allow-run ? true,
      ...
    }:
    pkg.overrideAttrs (
      _: prev:
      let
        name = if builtins.hasAttr "pname" then prev.pname else prev.name;
        binName = if target == "x86_64-pc-windows-msvc" then "${name}.exe" else name;

        denort = {
          x86_64-pc-windows-msvc = pkgs.fetchurl {
            url = "https://dl.deno.land/release/v2.6.5/denort-x86_64-pc-windows-msvc.zip";
            hash = "sha256-L7WJmj0SEhubMlO2/1a8dMzF8WZep03GQjSbVas3/u4=";
          };
          x86_64-apple-darwin = pkgs.fetchurl {
            url = "https://dl.deno.land/release/v2.6.5/denort-x86_64-apple-darwin.zip";
            hash = "sha256-4iwBoc9HlZOLLeW7Tu+QkswZIk5C4S7BE7BLhrMUUcM=";
          };
          aarch64-apple-darwin = pkgs.fetchurl {
            url = "https://dl.deno.land/release/v2.6.5/denort-aarch64-apple-darwin.zip";
            hash = "sha256-BjyJLUIaK+Huy7IAw8RSIdgRqzDENKlytkTdkO+3hR8=";
          };
          x86_64-unknown-linux-gnu = pkgs.fetchurl {
            url = "https://dl.deno.land/release/v2.6.5/denort-x86_64-unknown-linux-gnu.zip";
            hash = "sha256-V/eYi9WBUfokh0u722flQG3o2JyYIRrYqY9/5JS9znM=";
          };
          aarch64-unknown-linux-gnu = pkgs.fetchurl {
            url = "https://dl.deno.land/release/v2.6.5/denort-aarch64-unknown-linux-gnu.zip";
            hash = "sha256-rE6bKb2IzA18cSLzvvrWC5u2V2LvLuBq9DeqrTUFDwo=";
          };
        };
      in
      {
        doCheck = false;

        nativeBuildInputs =
          with pkgs;
          [
            deno
            jq
          ]
          ++ previousAttrs.nativeBuildInputs;

        # compile to binary with deno
        installPhase = ''
          runHook preInstall

          DENO_DIR="''${TMPDIR:-/tmp}/deno"
          export DENO_DIR

          # install denort for given target
          mkdir -p "$DENO_DIR/dl/release/v${pkgs.deno.version}"
          cp ${denort."${target}"} "$DENO_DIR/dl/release/v${pkgs.deno.version}/denort-${target}.zip"

          # find entrypoint
          ENTRYPOINT=$(jq -r '.main' package.json)
          if [ "$ENTRYPOINT" = "null" ] || [ -z "$ENTRYPOINT" ]; then
            ENTRYPOINT="build/index.js"
          fi

          # compile
          mkdir -p $out/bin
          deno compile \
            --no-check \
            ${if allow-read then "--allow-read" else "--deny-read"} \
            ${if allow-write then "--allow-write" else "--deny-write"} \
            ${if allow-net then "--allow-net" else "--deny-net"} \
            ${if allow-env then "--allow-env" else "--deny-env"} \
            ${if allow-run then "--allow-run" else "--deny-run"} \
            --target ${target} \
            --output "$out/bin/${binName}" "$ENTRYPOINT"

          runHook postInstall
        '';

        meta = prev.meta // {
          mainProgram = binName;
        };
      }
    )
  );
}
