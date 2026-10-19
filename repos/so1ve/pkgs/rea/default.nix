{
  autoPatchelfHook,
  buildNpmPackage,
  callPackage,
  lib,
  makeWrapper,
  nodejs_24,
  source ? callPackage ./source.nix { },
  stdenv,
}:

let
  frida = callPackage ./frida.nix { };
in
buildNpmPackage {
  pname = "rea";
  inherit (source) version npmDepsHash;

  src = ./.;
  nodejs = nodejs_24;
  npmFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [ stdenv.cc.cc.lib ];

  postConfigure = ''
    # Install Frida's pinned addon without its network-based install script.
    tar -xzf ${frida.src} -C node_modules/frida
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/rea"
    cp -r node_modules "$out/share/rea/"
    makeWrapper ${lib.getExe nodejs_24} "$out/bin/rea" \
      --add-flags "$out/share/rea/node_modules/rea-agents/scripts/rea.mjs"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    "$out/bin/rea" --version

    node --input-type=module <<'JS'
    import { createRequire } from 'node:module';
    import { pathToFileURL } from 'node:url';

    const require = createRequire(process.env.out + '/share/rea/node_modules/rea-agents/package.json');
    require('@lydell/node-pty');
    await import(pathToFileURL(require.resolve('frida')));
    JS

    runHook postInstallCheck
  '';

  meta = {
    description = "Reverse engineering CLI and MCP server for AI agents";
    homepage = "https://github.com/morluto/rea";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];
    mainProgram = "rea";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
