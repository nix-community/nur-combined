{
  lib,
  buildNpmPackage,
  callPackage,

  runCommand,
  jq,

  new-api,
}:

buildNpmPackage (finalAttrs: {
  pname = "${new-api.pname}-frontnd";
  inherit (new-api) version;

  src = runCommand "${finalAttrs.pname}-patched-src" { nativeBuildInputs = [ jq ]; } ''
    cp -r ${new-api.src} $out
    chmod -R +w $out
    jq '.overrides = {
      "vite": "^5.2.0",
      "react": "^18.2.0",
      "react-dom": "^18.2.0",
      "@lobehub/icons": { "react": "$react", "react-dom": "$react-dom" }
    }' $out/web/package.json > package.json && \
      mv package.json $out/web/package.json
  '';

  sourceRoot = "${finalAttrs.src.name}/web";

  postPatch = ''
    ln -s ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-pklFBCj8piXOGUaDwuVKi7E+/MFylLzngRCLKvC5L38=";

  installPhase = ''
    runHook preInstall

    cp -r dist $out

    runHook postInstall
  '';

  # nix-update auto -u
  passthru.updateScript = lib.getExe (callPackage ./update.nix { });

  inherit (new-api) meta;
})
