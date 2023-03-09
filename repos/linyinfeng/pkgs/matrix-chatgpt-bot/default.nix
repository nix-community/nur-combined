{ callPackage, sources, lib, mkYarnPackage, nodejs, makeWrapper, matrix-sdk-crypto-nodejs }:

mkYarnPackage {
  inherit (sources.matrix-chatgpt-bot) pname version src;

  packageJSON = ./package.json;
  yarnNix = ./yarn.nix;

  nativeBuildInputs = [
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild
    yarn --offline tsc
    runHook postBuild
  '';

  postInstall = ''
    out_node_path="$out/libexec/matrix-chatgpt-bot/node_modules"

    rm -r "$out_node_path/@matrix-org/matrix-sdk-crypto-nodejs"
    ln -s "${matrix-sdk-crypto-nodejs}/lib/node_modules/@matrix-org/matrix-sdk-crypto-nodejs" "$out_node_path/@matrix-org"

    makeWrapper ${nodejs}/bin/node "$out/bin/matrix-chatgpt-bot" \
      --add-flags "$out_node_path/matrix-chatgpt-bot/dist/index.js" \
      --prefix NODE_PATH : "$out_node_path"
  '';

  passthru = {
    updateScriptEnabled = true;
    updateScript = let script = callPackage ./update.nix { }; in [ "${script}" ];
  };

  meta = with lib; {
    description = "Talk to ChatGPT via any Matrix client";
    homepage = "https://github.com/matrixgpt/matrix-chatgpt-bot";
    license = licenses.agpl3;
    maintainers = with maintainers; [ yinfeng ];
  };
}
