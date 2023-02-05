{ vscode }:

vscode.overrideAttrs (finalAttrs: previousAttrs: {
  installPhase = previousAttrs.installPhase + ''
    chmod +x $out/lib/vscode/resources/app/node_modules/node-pty/build/Release/spawn-helper
    chmod +x $out/lib/vscode/resources/app/node_modules.asar.unpacked/node-pty/build/Release/spawn-helper
  '';
})
