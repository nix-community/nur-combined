{
  callPackage,
  fetchFromGitHub,
  lib,
  mkYarnPackage,
  nodejs,
  makeWrapper,
  matrix-sdk-crypto-nodejs,
}:

mkYarnPackage rec {
  pname = "matrix-chatgpt-bot";
  version = "3.1.5";
  src = fetchFromGitHub ({
    owner = "matrixgpt";
    repo = "matrix-chatgpt-bot";
    rev = "v${version}";
    sha256 = "sha256-/4eyzeLQBASCOglC6a6C0KNwtyzlUZgW68cEdMtARU8=";
  });

  packageJSON = ./package.json;
  yarnNix = ./yarn.nix;

  nativeBuildInputs = [ makeWrapper ];

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
    updateScript =
      let
        script = callPackage ./update.nix { };
      in
      [ "${script}" ];
  };

  meta = with lib; {
    description = "Talk to ChatGPT via any Matrix client";
    homepage = "https://github.com/matrixgpt/matrix-chatgpt-bot";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ yinfeng ];
  };
}
