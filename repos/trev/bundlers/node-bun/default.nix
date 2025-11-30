{
  pkgs,
  drv,
  target,
}:
drv.overrideAttrs (
  finalAttrs: previousAttrs:
  let
    binName = if target == "bun-windows-x64" then "${previousAttrs.pname}.exe" else previousAttrs.pname;
  in
  {
    pname = "${previousAttrs.pname}-${target}";

    doCheck = false;

    nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [
      pkgs.bun
      pkgs.upx
    ];

    # compile to binary with bun
    installPhase = ''
      runHook preInstall

       mkdir -p ''${out}/bin
       bun build --compile --minify --sourcemap \
        --target="${target}" \
        --outfile "''${out}/bin/${binName}" build/index.js

       runHook postInstall
    '';

    meta.mainProgram = binName;
  }
)
