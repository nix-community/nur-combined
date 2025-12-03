{
  pkgs,
  drv,
  target,
  normalized,
}:
drv.overrideAttrs (
  finalAttrs: previousAttrs:
  let
    binName =
      if target == "x86_64-pc-windows-msvc" then "${previousAttrs.pname}.exe" else previousAttrs.pname;

    denort = {
      x86_64-pc-windows-msvc = pkgs.fetchurl {
        url = "https://dl.deno.land/release/v2.5.6/denort-x86_64-pc-windows-msvc.zip";
        hash = "sha256-RK6GAwiRTuVXRfRBfkzllT8LlBAQeXP+yOhwsKBtKak=";
      };
      x86_64-apple-darwin = pkgs.fetchurl {
        url = "https://dl.deno.land/release/v2.5.6/denort-x86_64-apple-darwin.zip";
        hash = "sha256-dna2dri9QSDTxsRZDGs2EI86iNuI+TE2Oy3fePmpyCs=";
      };
      aarch64-apple-darwin = pkgs.fetchurl {
        url = "https://dl.deno.land/release/v2.5.6/denort-aarch64-apple-darwin.zip";
        hash = "sha256-K4HfRWSZWkG7IDEVHOUKa4kqjwTlCJ9hFXD2mTmG3lg=";
      };
      x86_64-unknown-linux-gnu = pkgs.fetchurl {
        url = "https://dl.deno.land/release/v2.5.6/denort-x86_64-unknown-linux-gnu.zip";
        hash = "sha256-qCuGkPfCb23wgFoRReAhCPQ3o6GtagWnIyuuAdqw7Ns=";
      };
      aarch64-unknown-linux-gnu = pkgs.fetchurl {
        url = "https://dl.deno.land/release/v2.5.6/denort-aarch64-unknown-linux-gnu.zip";
        hash = "sha256-rE6bKb2IzA18cSLzvvrWC5u2V2LvLuBq9DeqrTUFDwo=";
      };
    };
  in
  {
    pname = "${previousAttrs.pname}-${normalized}";

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
        --allow-env \
        --allow-net \
        --target ${target} \
        --output "$out/bin/${binName}" "$ENTRYPOINT"

      runHook postInstall
    '';

    meta.mainProgram = binName;
  }
)
