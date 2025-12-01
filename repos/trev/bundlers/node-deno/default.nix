{
  pkgs,
  drv,
  target,
}:
drv.overrideAttrs (
  finalAttrs: previousAttrs:
  let
    binName =
      if target == "x86_64-pc-windows-msvc" then "${previousAttrs.pname}.exe" else previousAttrs.pname;
  in
  {
    pname = "${previousAttrs.pname}-${target}";

    doCheck = false;

    nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [
      pkgs.deno
    ];

    # compile to binary with deno
    installPhase = ''
      runHook preInstall

       mkdir -p ''${out}/bin
       deno compile --target ${target} --output "''${out}/bin/${binName}" build/index.js

       runHook postInstall
    '';

    meta.mainProgram = binName;
  }
)
