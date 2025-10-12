{
  buildNpmPackage,
  cairo,
  fetchFromGitHub,
  giflib,
  lib,
  libjpeg,
  librsvg,
  meta,
  nodejs,
  pango,
  pixman,
  pkg-config,
  typescript,
  version,
  bun,
  withBun ? false,
  ...
}:
buildNpmPackage (finalAttrs: {
  inherit
    nodejs
    version
    meta
    ;

  pname = "bgutil-ytdlp-pot-provider-server";

  src = fetchFromGitHub {
    owner = "Brainicism";
    repo = "bgutil-ytdlp-pot-provider";
    rev = version;
    hash = "sha256-KKImGxFGjClM2wAk/L8nwauOkM/gEwRVMZhTP62ETqY=";
  };

  sourceRoot = "${finalAttrs.src.name}/server";

  nativeBuildInputs = [
    pkg-config
    typescript
  ];

  buildInputs = [
    cairo
    giflib
    libjpeg
    librsvg
    pango
    pixman
  ];

  makeCacheWritable = true;
  npmDepsHash = "sha256-lCK7ukI60Exe+PW0rATm3szzWDv8AaVJPS6Hl9Rfm18=";

  buildPhase = ''
    runHook preBuild

    tsc

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r build $out/build
    sed -i "1i\#!${lib.getExe (if withBun then bun else finalAttrs.nodejs)}" $out/build/main.js
    cp -r node_modules $out/node_modules
    ln -s $out/build/main.js $out/bin/bgutil-ytdlp-pot-provider
    chmod +x $out/bin/bgutil-ytdlp-pot-provider

    runHook postInstall
  '';
})
